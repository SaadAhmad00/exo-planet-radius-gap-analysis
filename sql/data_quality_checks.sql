-- ============================================================
-- Data Quality & Aggregate Checks
-- Run before trusting any pattern in the radius gap analysis.
-- These queries check completeness, ranges, and distribution
-- shape across the key columns.
-- ============================================================


-- ------------------------------------------------------------
-- 1. Total row count, baseline for everything below
-- ------------------------------------------------------------
SELECT COUNT(*) AS total_planets
FROM Exoplanets;


-- ------------------------------------------------------------
-- 2. Missing value count across every column used in analysis
-- COUNT(*) counts every row; COUNT(column) skips NULLs in that
-- column. Subtracting the two gives the missing count directly.
-- ------------------------------------------------------------
SELECT
    COUNT(*) - COUNT(pl_rade)   AS missing_radius,
    COUNT(*) - COUNT(pl_bmasse) AS missing_mass,
    COUNT(*) - COUNT(pl_orbper) AS missing_orbital_period,
    COUNT(*) - COUNT(pl_eqt)    AS missing_eq_temp,
    COUNT(*) - COUNT(st_teff)   AS missing_star_temp,
    COUNT(*) - COUNT(sy_dist)   AS missing_distance,
    COUNT(*) - COUNT(disc_year) AS missing_year
FROM Exoplanets;


-- ------------------------------------------------------------
-- 3. Percent completeness for the radius column specifically
-- Turns a raw missing count into something easier to reason
-- about at a glance, e.g. "95% complete" vs "240 missing"
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS total_rows,
    COUNT(pl_rade) AS rows_with_radius,
    CAST(COUNT(pl_rade) AS FLOAT) / COUNT(*) * 100 AS percent_complete
FROM Exoplanets;


-- ------------------------------------------------------------
-- 4. Min, max, and average for every numeric column used
-- Gives a feel for realistic ranges before bucketing, and
-- flags anything wildly out of scale
-- ------------------------------------------------------------
SELECT
    MIN(pl_rade)   AS min_radius,   MAX(pl_rade)   AS max_radius,   AVG(pl_rade)   AS avg_radius,
    MIN(pl_bmasse) AS min_mass,     MAX(pl_bmasse) AS max_mass,     AVG(pl_bmasse) AS avg_mass,
    MIN(pl_orbper) AS min_period,   MAX(pl_orbper) AS max_period,   AVG(pl_orbper) AS avg_period,
    MIN(st_teff)   AS min_star_temp, MAX(st_teff)  AS max_star_temp, AVG(st_teff)  AS avg_star_temp
FROM Exoplanets;


-- ------------------------------------------------------------
-- 5. Standard deviation on radius
-- Shows how spread out the values are, not just the average,
-- useful context for whether a 20-25% dip is actually notable
-- ------------------------------------------------------------
SELECT
    AVG(pl_rade) AS avg_radius,
    STDEV(pl_rade) AS stdev_radius
FROM Exoplanets
WHERE pl_rade IS NOT NULL;


-- ------------------------------------------------------------
-- 6. Distinct value counts
-- How many unique discovery methods and host stars are we
-- actually working with?
-- ------------------------------------------------------------
SELECT
    COUNT(DISTINCT discoverymethod) AS unique_discovery_methods,
    COUNT(DISTINCT hostname) AS unique_host_stars,
    COUNT(DISTINCT disc_year) AS years_covered
FROM Exoplanets;


-- ------------------------------------------------------------
-- 7. Sanity check: any impossible or suspicious values?
-- Negative radius or mass would indicate a data problem
-- ------------------------------------------------------------
SELECT COUNT(*) AS suspicious_rows
FROM Exoplanets
WHERE pl_rade < 0 OR pl_bmasse < 0 OR pl_orbper < 0;


-- ------------------------------------------------------------
-- 8. Row totals after applying the analysis filter
-- Confirms how many planets actually made it into the radius
-- gap analysis after WHERE pl_rade BETWEEN 1.0 AND 3.0
-- ------------------------------------------------------------
SELECT COUNT(*) AS planets_in_analysis_range
FROM Exoplanets
WHERE pl_rade BETWEEN 1.0 AND 3.0;
