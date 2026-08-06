import requests
import psycopg2
from collections import defaultdict
import time
import os
from dotenv import load_dotenv

load_dotenv()
NOAA_TOKEN = os.getenv("NOAA_TOKEN")

STATIONS = {
    "New York":    "GHCND:USW00094728",
    "Chicago":     "GHCND:USW00094846",
    "Los Angeles": "GHCND:USW00023174",
    "Houston":     "GHCND:USW00012960",
    "Phoenix":     "GHCND:USW00023183",
}

url = "https://www.ncei.noaa.gov/cdo-web/api/v2/data"
headers = {"token": NOAA_TOKEN}

conn = psycopg2.connect(dbname="nyc_air_climate", user="amaryllis", host="localhost", port="5432")
cur = conn.cursor()

for city_name, station_id in STATIONS.items():
    print(f"\n=== {city_name} ===")

    cur.execute("SELECT city_id FROM cities WHERE city_name = %s", (city_name,))
    row = cur.fetchone()
    city_id = row[0]

    all_results = []
    for year in range(2015, 2026):
        params = {
            "datasetid": "GHCND",
            "stationid": station_id,
            "startdate": f"{year}-01-01",
            "enddate": f"{year}-12-31",
            "datatypeid": "TMAX,TMIN",
            "units": "standard",
            "limit": 1000,
        }
        response = requests.get(url, headers=headers, params=params)
        data = response.json()
        results = data.get("results", [])

        print(f"{year}: pulled {len(results)} rows")
        all_results.extend(results)
        time.sleep(1)

    by_date = defaultdict(dict)
    for row in all_results:
        date = row["date"][:10]
        by_date[date][row["datatype"]] = row["value"]

    print(f"Pivoted to {len(by_date)} unique dates")

    for date, values in by_date.items():
        cur.execute("""
            INSERT INTO weather_readings (city_id, reading_date, max_temp_f, min_temp_f)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (city_id, reading_date) DO NOTHING
        """, (city_id, date, values.get("TMAX"), values.get("TMIN")))

    conn.commit()
    print(f"{city_name} done inserting")

cur.close()
conn.close()
print("\nAll cities complete")