import requests
import psycopg2
from collections import defaultdict
import time
import os
from dotenv import load_dotenv

load_dotenv()

EMAIL = os.getenv("EPA_EMAIL")
KEY = os.getenv("EPA_KEY")

# city_name -> list of (state, county) pairs to pull
CITY_COUNTIES = {
    "New York": [
        ("36", "061"),  # Manhattan
        ("36", "005"),  # Bronx
        ("36", "047"),  # Brooklyn
        ("36", "081"),  # Queens
        ("36", "085"),  # Staten Island
    ],
    "Chicago":     [("17", "031")],
    "Los Angeles": [("06", "037")],
    "Houston":     [("48", "201")],
    "Phoenix":     [("04", "013")],
}

url = "https://aqs.epa.gov/data/api/dailyData/byCounty"

conn = psycopg2.connect(dbname="nyc_air_climate", user="amaryllis", host="localhost", port="5432")
cur = conn.cursor()

for city_name, counties in CITY_COUNTIES.items():
    print(f"\n=== {city_name} ===")

    cur.execute("SELECT city_id FROM cities WHERE city_name = %s", (city_name,))
    city_id = cur.fetchone()[0]

    all_data = []
    for state_code, county_code in counties:
        print(f"  -- county {state_code}-{county_code} --")
        for year in range(2015, 2026):
            params = {
                "email": EMAIL,
                "key": KEY,
                "param": "88101",
                "bdate": f"{year}0101",
                "edate": f"{year}1231",
                "state": state_code,
                "county": county_code,
            }
            response = requests.get(url, params=params)
            result = response.json()

            if result["Header"][0]["status"] != "Success":
                print(f"  {year}: FAILED — {result['Header'][0]}")
                continue

            year_data = result["Data"]
            print(f"  {year}: pulled {len(year_data)} rows")
            all_data.extend(year_data)
            time.sleep(1)

    grouped = defaultdict(list)
    station_info = {}
    for row in all_data:
        station_id = f"{row['state_code']}-{row['county_code']}-{row['site_number']}"
        key = (station_id, row['date_local'])
        grouped[key].append(row)
        station_info[station_id] = (row['latitude'], row['longitude'])

    for station_id, (lat, lon) in station_info.items():
        cur.execute("""
            INSERT INTO stations (station_id, city_id, latitude, longitude)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (station_id) DO NOTHING
        """, (station_id, city_id, lat, lon))

    for (station_id, date), rows in grouped.items():
        pm25_values = [r['arithmetic_mean'] for r in rows if r['arithmetic_mean'] is not None]
        aqi_values = [r['aqi'] for r in rows if r['aqi'] is not None]
        avg_pm25 = sum(pm25_values) / len(pm25_values) if pm25_values else None
        avg_aqi = round(sum(aqi_values) / len(aqi_values)) if aqi_values else None

        cur.execute("""
            INSERT INTO daily_readings (station_id, reading_date, pm25, aqi)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT DO NOTHING
        """, (station_id, date, avg_pm25, avg_aqi))

    conn.commit()
    print(f"{city_name} done inserting")

cur.close()
conn.close()
print("\nAll cities complete")