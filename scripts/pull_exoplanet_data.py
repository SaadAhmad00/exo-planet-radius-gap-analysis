"""
Pulls confirmed exoplanet data from the NASA Exoplanet Archive
and saves it as a clean CSV ready to import into SSMS.

No API key needed - this archive is open access via TAP (Table Access Protocol).
"""

import requests
import pandas as pd

# TAP query - pulling the columns we actually need for EDA
# pl_name = planet name, hostname = star name, disc_year = discovery year,
# discoverymethod = how it was found, pl_orbper = orbital period (days),
# pl_rade = planet radius (Earth radii), pl_bmasse = planet mass (Earth masses),
# pl_eqt = equilibrium temp (K), st_teff = host star temp (K),
# sy_dist = distance from Earth (parsecs)
query = """
SELECT pl_name, hostname, disc_year, discoverymethod,
       pl_orbper, pl_rade, pl_bmasse, pl_eqt, st_teff, sy_dist
FROM ps
WHERE default_flag = 1
"""

url = "https://exoplanetarchive.ipac.caltech.edu/TAP/sync"
params = {
    "query": query,
    "format": "csv"
}

print("Requesting data from NASA Exoplanet Archive...")
response = requests.get(url, params=params)
response.raise_for_status()

# Save raw response to CSV
with open("exoplanets_raw.csv", "wb") as f:
    f.write(response.content)

# Quick sanity check with pandas before we call it done
df = pd.read_csv("exoplanets_raw.csv")
print(f"Pulled {len(df)} rows, {len(df.columns)} columns")
print(df.head())

# Save a cleaned version too (drop rows with no discovery year, since that's
# central to time-trend analysis)
df_clean = df.dropna(subset=["disc_year"])
df_clean.to_csv("exoplanets_clean.csv", index=False)
print(f"Saved exoplanets_clean.csv with {len(df_clean)} rows")
