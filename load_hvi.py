import csv
import psycopg2

conn = psycopg2.connect(dbname="nyc_air_climate", user="amaryllis", host="localhost", port="5432")
cur = conn.cursor()

with open("heat_vulnerability_index_rankings.csv", newline="") as f:
    reader = csv.DictReader(f)
    count = 0
    for row in reader:
        zip_code = row["ZIP Code Tabulation Area (ZCTA) 2020"]
        hvi_score = row["Heat Vulnerability Index (HVI)"]

        cur.execute("""
            INSERT INTO heat_vulnerability (zip_code, hvi_score)
            VALUES (%s, %s)
            ON CONFLICT (zip_code) DO NOTHING
        """, (zip_code, hvi_score))
        count += 1

conn.commit()
cur.close()
conn.close()
print(f"Loaded {count} rows")