-- Exoplanet Radius Gap Analysis
-- Data source: NASA Exoplanet Archive (Planetary Systems table)
-- Table: dbo.Exoplanets

-- ============================================================
-- Step 1: Initial pass with wide bins (0.5 Earth radii)
-- Result: no clear dip visible, bins too coarse to catch the gap
-- ============================================================
SELECT
    CASE
        WHEN pl_rade < 1.0 THEN '< 1.0 (Earth-like)'
        WHEN pl_rade >= 1.0 AND pl_rade < 1.5 THEN '1.0 - 1.5'
        WHEN pl_rade >= 1.5 AND pl_rade < 2.0 THEN '1.5 - 2.0'
        WHEN pl_rade >= 2.0 AND pl_rade < 4.0 THEN '2.0 - 4.0 (sub-Neptune)'
        ELSE '4.0+ (giant)'
    END AS radius_bucket,
    COUNT(*) AS planet_count
FROM dbo.Exoplanets
WHERE pl_rade IS NOT NULL
GROUP BY
    CASE
        WHEN pl_rade < 1.0 THEN '< 1.0 (Earth-like)'
        WHEN pl_rade >= 1.0 AND pl_rade < 1.5 THEN '1.0 - 1.5'
        WHEN pl_rade >= 1.5 AND pl_rade < 2.0 THEN '1.5 - 2.0'
        WHEN pl_rade >= 2.0 AND pl_rade < 4.0 THEN '2.0 - 4.0 (sub-Neptune)'
        ELSE '4.0+ (giant)'
    END
ORDER BY MIN(pl_rade);

-- ============================================================
-- Step 2: Finer bins (0.1 Earth radii) across the range where
-- the radius gap is expected to sit
-- Result: visible dip in planet count around 1.8-1.9 Earth radii
-- ============================================================
SELECT
    FLOOR(pl_rade * 10) / 10.0 AS radius_bin,
    COUNT(*) AS planet_count
FROM dbo.Exoplanets
WHERE pl_rade IS NOT NULL AND pl_rade BETWEEN 1.0 AND 3.0
GROUP BY FLOOR(pl_rade * 10) / 10.0
ORDER BY radius_bin;

-- ============================================================
-- Step 3: Supporting analysis, restrict to Sun-like host stars
-- (effective temperature 5300-6000K) to check if the gap still
-- holds for this subset, since the radius gap was originally
-- studied around stars like our own Sun
-- ============================================================
SELECT
    FLOOR(pl_rade * 10) / 10.0 AS radius_bin,
    COUNT(*) AS planet_count
FROM dbo.Exoplanets
WHERE pl_rade IS NOT NULL
  AND pl_rade BETWEEN 1.0 AND 3.0
  AND st_teff BETWEEN 5300 AND 6000
GROUP BY FLOOR(pl_rade * 10) / 10.0
ORDER BY radius_bin;
