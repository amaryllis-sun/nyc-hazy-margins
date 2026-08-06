# Hazy Margins: Air Quality &amp; Rising Heat in NYC

A SQL-driven investigation into whether NYC's air quality and heat are actually getting worse — using eleven years of real federal data, not assumptions.

**[Read the full write-up with charts →](nyc_climate_report.html)**

## The question

I live in Manhattan, and the last couple of summers have felt hazier and hotter than I remembered. Rather than take that feeling at face value, I built a PostgreSQL database from public EPA and NOAA data to check it — and to compare NYC against four other major U.S. cities.

## What's in this repo

| File | What it does |
|---|---|
| `epa_pull.py` | Pulls daily PM2.5/AQI data from the EPA Air Quality System API, for 5 cities (all 5 NYC boroughs + 4 comparison cities), 2015–2025 |
| `noaa_pull.py` | Pulls daily max/min temperature from NOAA's Climate Data Online API for the same cities |
| `geocode_stations.py` | Reverse-geocodes each EPA station's lat/long to a ZIP code via the Census Bureau's free geocoder |
| `load_hvi.py` | Loads NYC's Heat Vulnerability Index (by ZIP code) from NYC Open Data |
| `nyc_climate_report.html` | The full findings write-up, with interactive charts |
| `schema.sql` | The database schema (tables + constraints) |

## Data sources

- **EPA Air Quality System API** — daily PM2.5 and AQI by monitoring station
- **NOAA Climate Data Online API** — daily max/min temperature
- **NYC Open Data** — Heat Vulnerability Index Rankings, by ZIP code
- **U.S. Census Bureau Geocoder** — lat/long → ZIP code lookup

## Schema

```
cities (city_id, city_name, state)
  └─ stations (station_id, city_id, latitude, longitude, zip_code)
       └─ daily_readings (station_id, reading_date, pm25, aqi)
  └─ weather_readings (city_id, reading_date, max_temp_f, min_temp_f)

heat_vulnerability (zip_code, hvi_score)   -- joined to stations via zip_code
```

Every table above unique-constrains on its natural key (`station_id`, `city_id + reading_date`, etc.) — added after an early bug where duplicate EPA instrument readings (POCs) silently inflated row counts. That bug, and the fix, are documented in the write-up.

## Key findings

- **NYC's yearly average AQI has no clean multi-year trend** (2015–2025 ranges 36–47) — the one real outlier, 2023, is the Canadian wildfire smoke event, not a gradual shift.
- **Hot days (90°F+) are trending up**, but modestly and noisily: a linear regression puts it at **+0.5 days/year** with **R² = 0.19** — a real but weak signal, mostly swamped by year-to-year weather variation.
- **Air quality is measurably worse on hot days**: average AQI is 58 on 90°F+ days vs. 39 on days under 80°F.
- **Across 5 cities**, Los Angeles has the highest average AQI and more than triple the unhealthy-air days of any other city in the comparison — despite Houston posting a similar average.
- **Within NYC**, Manhattan's monitors average the highest AQI; the outer boroughs run a few points lower.
- **NYC's Heat Vulnerability Index doesn't correlate cleanly with measured air quality** — a useful negative result, since HVI is built from income/green-space/AC-access, not pollution data. It measures who's most at risk when heat hits, not where the air is dirtiest.

## Honest limitations

- NYC's 5-borough comparison rests on only 14 EPA monitors total (2–4 per borough) — enough for a city-scale pattern, not neighborhood-level certainty.
- Temperature for all 5 boroughs comes from one station (Central Park); only air quality is borough-specific.
- Hot-day and air-quality correlation doesn't isolate heat from "summer" generally (ozone chemistry, wildfire season, and wind patterns all cluster in the same months).
- Five cities over eleven years is a real sample, not a comprehensive one.

## Tools

PostgreSQL · Python (psycopg2, requests) · DBeaver · EPA AQS API · NOAA CDO API · NYC Open Data · U.S. Census Geocoder

---
*A personal project, summer 2026.*
