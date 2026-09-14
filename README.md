# Exoplanet Radius Gap Analysis

An exploratory data analysis project using live data from the NASA Exoplanet Archive to check whether a known astrophysical pattern, the "radius gap," shows up in the current confirmed planet dataset.

## What is the radius gap?

Astronomers have observed that exoplanets between roughly 1.5 and 2.0 Earth radii are underrepresented compared to planets just below or above that range. The leading explanation is atmospheric stripping: planets in this size range tend to lose their atmospheres to radiation from their host star, leaving them either small and rocky, or large enough to hold onto a thick atmosphere as a sub-Neptune. Few planets stay stuck in between.

## Pipeline

1. **`pull_exoplanet_data.py`** pulls confirmed exoplanet data directly from the NASA Exoplanet Archive's TAP API (no API key required) and exports it to CSV.
2. Data is imported into SQL Server (SSMS) for analysis.
3. SQL queries in `/sql` bucket planets by radius and count them.

## Finding

Bucketing planets into wide (0.5 Earth radii) bins initially showed no clear pattern. Switching to finer 0.1 Earth radii bins revealed a visible dip in planet count around **1.8-1.9 Earth radii**, roughly a 20-25% drop compared to the neighboring bins, consistent with the published radius gap.

<img width="570" height="269" alt="image" src="https://github.com/user-attachments/assets/a810766d-70b1-4d78-a662-775d49cc8bab" />


This also demonstrated a methodology point: bin width choice can hide or reveal real patterns in a dataset. The gap wasn't visible until the bin size was narrowed.

## Tools used

- Python (requests, pandas) for data extraction
- SQL Server / SSMS for querying and aggregation

## Data source

[NASA Exoplanet Archive](https://exoplanetarchive.ipac.caltech.edu/), Planetary Systems (PS) table, confirmed planets only (`default_flag = 1`).

