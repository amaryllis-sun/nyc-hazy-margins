import requests
import psycopg2

conn = psycopg2.connect(dbname="nyc_air_climate", user="amaryllis", host="localhost", port="5432")
cur = conn.cursor()

cur.execute("ALTER TABLE stations ADD COLUMN IF NOT EXISTS zip_code VARCHAR(5)")
conn.commit()  # commit this immediately, so it sticks no matter what happens next

cur.execute("""
    SELECT s.station_id, s.latitude, s.longitude 
    FROM stations s
    WHERE s.city_id = (SELECT city_id FROM cities WHERE city_name = 'New York')
""")
nyc_stations = cur.fetchall()
print(f"Found {len(nyc_stations)} NYC stations to geocode")

for station_id, lat, lon in nyc_stations:
    url = "https://geocoding.geo.census.gov/geocoder/geographies/coordinates"
    params = {
        "x": lon,
        "y": lat,
        "benchmark": "Public_AR_Current",
        "vintage": "Current_Current",
        "layers": "2020 Census ZIP Code Tabulation Areas",
        "format": "json",
    }

    try:
        response = requests.get(url, params=params, timeout=10)
        data = response.json()
        zip_code = data["result"]["geographies"]["2020 Census ZIP Code Tabulation Areas"][0]["ZCTA5"]
    except Exception as e:
        print(f"FAILED for station {station_id}: {e}")
        continue

    cur.execute("UPDATE stations SET zip_code = %s WHERE station_id = %s", (zip_code, station_id))
    conn.commit()  # commit after each station, so progress isn't lost if a later one fails
    print(f"{station_id} -> ZIP {zip_code}")

cur.close()
conn.close()
print("Done geocoding")