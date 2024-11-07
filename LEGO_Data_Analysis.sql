	-- Data set: https://rebrickable.com/downloads/
    
    -- COLOR ANALYSIS --

-- Total colors
SELECT 
	COUNT(*) AS total_colors 
FROM colors;

-- What are the most popular colors of parts used across all sets?
SELECT 
    colors.name AS color_name,
    COUNT(*) AS usage_count
FROM inventory_parts 
JOIN colors ON inventory_parts.color_id = colors.id
GROUP BY colors.name
ORDER BY usage_count DESC
LIMIT 10;

-- Are there specific colors that are more common in certain sets?
WITH color_counts AS (
    SELECT 
        sets.set_num,
        sets.name AS set_name,
        colors.name AS color_name,
        COUNT(*) AS color_count,
        RANK() OVER (PARTITION BY sets.set_num ORDER BY COUNT(*) DESC) AS color_rank
    FROM inventory_parts
    JOIN inventories ON inventory_parts.inventory_id = inventories.id
    JOIN sets ON inventories.set_num = sets.set_num
    JOIN colors ON inventory_parts.color_id = colors.id
    WHERE colors.name NOT IN ('[No Color/Any Color]')
    GROUP BY sets.set_num, sets.name, colors.name
)
SELECT 
    set_num,
    set_name,
    color_name,
    color_count
FROM color_counts
WHERE color_rank = 1
ORDER BY set_name;

-- Have the Colors of LEGOs in sets Changed Over Time?
SELECT 
    sets.year,
    colors.name AS color_name,
    COUNT(*) AS color_count
FROM inventory_parts
JOIN inventories ON inventory_parts.inventory_id = inventories.id
JOIN sets ON inventories.set_num = sets.set_num
JOIN colors ON inventory_parts.color_id = colors.id
WHERE colors.name NOT IN ('[No Color/Any Color]')
GROUP BY sets.year, colors.name
ORDER BY color_name, color_count DESC;

	-- LEGO SET COMPLEXITY ANALYSIS
-- How has the average number of parts per set changed by year?        
SELECT year, AVG(num_parts) AS avg_num_parts
FROM sets
GROUP BY year
ORDER BY year;

-- Which themes have the highest average number of parts per set?
SELECT themes.name, AVG(num_parts) AS avg_num_parts
FROM sets
JOIN themes ON sets.theme_id = themes.id
GROUP BY themes.name
ORDER BY avg_num_parts DESC;

	-- MINIFIGURE ANALYSIS
-- Which minifigs appear in the most LEGO sets?
SELECT minifigs.name AS minifig_name, COUNT(im.inventory_id) AS set_count
FROM inventory_minifigs im
JOIN minifigs ON im.fig_num = minifigs.fig_num
GROUP BY minifigs.name
ORDER BY set_count DESC
LIMIT 10;

-- What’s the trend in the number of minifigs included in sets over time?
SELECT sets.year, COUNT(im.fig_num) AS num_minifigs
FROM inventory_minifigs im
JOIN inventories ON im.inventory_id = inventories.id
JOIN sets ON inventories.set_num = sets.set_num
GROUP BY sets.year
ORDER BY sets.year;

	-- PART ANALYSIS
-- What are the most common parts in all sets?
SELECT parts.name AS part_name, COUNT(ip.part_num) AS part_count
FROM inventory_parts ip
JOIN parts ON ip.part_num = parts.part_num
GROUP BY parts.name
ORDER BY part_count DESC;

-- What sets have the most common parts?
-- Step 1: Find the most common parts
WITH common_parts AS (
    SELECT 
        ip.part_num,
        parts.name AS part_name,
        COUNT(*) AS appearance_count
    FROM inventory_parts ip
    JOIN parts ON ip.part_num = parts.part_num
    GROUP BY ip.part_num, parts.name
    ORDER BY appearance_count DESC
    LIMIT 10  -- Top 10 most-used parts
)

-- Step 2: Find sets containing these most-used parts
SELECT 
    sets.set_num,
    sets.name AS set_name,
    common_parts.part_num,
    common_parts.part_name,
    common_parts.appearance_count
FROM common_parts
JOIN inventory_parts ip ON common_parts.part_num = ip.part_num
JOIN inventories ON ip.inventory_id = inventories.id
JOIN sets ON inventories.set_num = sets.set_num
ORDER BY common_parts.appearance_count DESC, sets.set_num;

-- What Sets Have the Rarest Parts?
-- Step 1: Find rare parts
WITH rare_parts AS (
    SELECT 
        ip.part_num,
        parts.name AS part_name,
        COUNT(*) AS appearance_count
    FROM inventory_parts ip
    JOIN parts ON ip.part_num = parts.part_num
    GROUP BY ip.part_num, parts.name
    HAVING appearance_count = 1  -- Parts appearing only once
)

-- Step 2: Find sets containing these rare parts
SELECT 
    sets.set_num,
    sets.name AS set_name,
    rare_parts.part_num,
    rare_parts.part_name
FROM rare_parts rp
JOIN inventory_parts ip ON rare_parts.part_num = ip.part_num
JOIN inventories i ON ip.inventory_id = i.id
JOIN sets ON i.set_num = sets.set_num;


