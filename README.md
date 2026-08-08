# Hazy Margins: Air Quality &amp; Rising Heat in NYC
By: Amaryllis Sun

A SQL and Python-driven analysis of whether NYC's air quality and heat are actually getting worse. Here, eleven years of real federal and city data are used, not just assumptions.

**[Read the full write-up with charts →](nyc_climate_report.html)**

## The Mission of This Project

My name is Amaryllis and I've lived in NYC my whole life. Recently, every summer seems to be hotter than the last. Weather reports seem to constantly record spikes up to 100 degrees, while nearby wildfires bring smoke and other pollutants to the city, making the sky hazier and New Yorkers concerned. So, I wanted to look into this phenomenon and think beyond face-value, using actual data to prove (or challenge) my hypotheses. I built a PostgreSQL database from public EPA and NOAA data to support my findings, and in turn, to compare NYC against four other major U.S. cities.

## Breaking Down This Repo

| File | Purpose |
|---|---|
| `epa_pull.py` | Pulls daily PM2.5/AQI data from the EPA Air Quality System API for 5 cities (all 5 NYC boroughs + 4 comparison cities), 2015–2025 |
| `noaa_pull.py` | Pulls daily max/min temperature from NOAA's Climate Data Online API for the same cities |
| `geocode_stations.py` | Reverse-geocodes each EPA station's latitude and longitude to a matching ZIP code via the Census Bureau's geocoder |
| `load_hvi.py` | Loads NYC's Heat Vulnerability Index (by ZIP code) from NYC Open Data |
| `nyc_climate_report.html` | All the findings written-up with interactive charts and tables |
| `schema.sql` | The database schema (tables + constraints) |

## Data Sources

- **EPA Air Quality System API** — daily PM2.5 and AQI by monitoring station
- **NOAA Climate Data Online API** — daily max/min temperature
- **NYC Open Data** — Heat Vulnerability Index Rankings by ZIP code
- **U.S. Census Bureau Geocoder** — latitude/longitude → ZIP code lookup

## Schema

```
cities (city_id, city_name, state)
  └─ stations (station_id, city_id, latitude, longitude, zip_code)
       └─ daily_readings (station_id, reading_date, pm25, aqi)
  └─ weather_readings (city_id, reading_date, max_temp_f, min_temp_f)

heat_vulnerability (zip_code, hvi_score)   -- joined to stations via zip_code
```

Every table above has unique constraints on its key (`station_id`, `city_id + reading_date`, etc.), which was added after an early bug where duplicate EPA instrument readings silently inflated row counts. That bug, and how it was fixed, are both included in the write-up.

## Key Findings

- **NYC's yearly average AQI has no clean multi-year trend** (2015–2025 ranges from an AQI of 36–47). The one real outlier, 2023, is the Canadian wildfire smoke event, and it can be expected that 2026 will have a similar result from another Canadian wildfire.
- **Hot days (90°F+) are on the rise**, but subtly: A linear regression model puts it at **+0.5 days/year** with **R² = 0.19**, a real but weak signal, likely confused by the weather varying from year-to-year.
- **Air quality is measurably worse on hot days**: Average AQI is 58 on 90°F+ days vs. 39 on days under 80°F.
- **Across 5 cities**, Los Angeles has the highest average AQI and more than triple the unhealthy-air days of any other city in the comparison.
- **Within NYC**, Manhattan's monitoring stations average the highest AQI while the outer boroughs run a few digits lower.
- **NYC's Heat Vulnerability Index (HVI) doesn't correlate cleanly with measured air quality**: An expected negative result, since HVI is measured by median-income/green-space/AC-access, not pollution data. It finds who's the most at risk in a heat wave, not necessarily where the air is dirtiest.

## Honest Limitations

- NYC's 5-borough comparison rests on only 14 EPA monitors total (2–4 per borough), enough to see patterns on the city-scale, but doesn't exactly produce neighborhood-level certainty.
- The temperature for all 5 boroughs comes from one station (located in Central Park) because other stations lacked consistency and data. Only the air quality is borough-specific.
- Hot-day and air-quality correlation doesn't protect heat from "summer" generalities (ozone chemistry, wildfire season, and wind patterns all cluster in the same months).
- Five cities over eleven years is a real sample, not a comprehensive one.

## Tools

PostgreSQL · Python (psycopg2, requests) · DBeaver · EPA AQS API · NOAA CDO API · NYC Open Data · U.S. Census Geocoder

---
*A personal project, summer 2026.*
