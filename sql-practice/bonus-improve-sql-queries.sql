----------
-- Step 0 - Create a Query
----------
-- Query: Find a count of `toys` records that have a price greater than
    -- 55 and belong to a cat that has the color "Olive".

    -- SELECT toys.id, toys.name, toys.price FROM toys
    -- SELECT * FROM toys
    -- EXPLAIN QUERY PLAN

    -- SELECT COUNT(*) FROM toys
    --     JOIN cat_toys ON (toys.id = cat_toys.toy_id)
    --     JOIN cats ON (cat_toys.cat_id = cats.id)
    --     WHERE toys.price > 55 AND cats.color = 'Olive';

    -- THIS QUERY ^^ WORKS BUT DOES NOT IMPROVE w INDEX on cat_toys(toy_id)
    -- reworking query & index below with Claude suggestion \/

-- Paste your results below (as a comment):

-- ┌──────────┐
-- │ COUNT(*) │
-- ├──────────┤
-- │ 215      │
-- └──────────┘
-- Run Time: real 0.004 user 0.000000 sys 0.000000

----------
-- Step 1 - Analyze the Query
----------
-- Query:

-- EXPLAIN QUERY PLAN
SELECT COUNT(*) FROM toys
    JOIN cat_toys ON (toys.id = cat_toys.toy_id)
    JOIN cats ON (cat_toys.cat_id = cats.id)
    WHERE toys.price > 55 AND cats.color = 'Olive';

-- Paste your results below (as a comment):

-- EXPLAIN QUERY PLAN <QUERY>
-- |--SCAN cat_toys
-- |--SEARCH toys USING INTEGER PRIMARY KEY (rowid=?)
-- `--SEARCH cats USING INTEGER PRIMARY KEY (rowid=?)

-- What do your results mean?

    -- Was this a SEARCH or SCAN?
    -- Cat toys table is scanned row by row,
    -- then toys & cats tables are searched by index

    -- What does that mean?
    -- I could speed things up by adding index to cat_toys



----------
-- Step 2 - Time the Query to get a baseline
----------
-- Query (to be used in the sqlite CLI):

    -- .timer ON

-- Paste your results below (as a comment):

-- ┌──────────┐
-- │ COUNT(*) │
-- ├──────────┤
-- │ 215      │
-- └──────────┘
-- Run Time: real 0.004 user 0.000000 sys 0.000000



----------
-- Step 3 - Add an index and analyze how the query is executing
----------

-- Create index:

-- NOT IMPROVING
-- CREATE INDEX idx_toy_id ON cat_toys(toy_id);

-- -- Analyze Query:
-- EXPLAIN QUERY PLAN
-- SELECT COUNT(*) FROM toys
--     JOIN cat_toys ON (toys.id = cat_toys.toy_id)
--     JOIN cats ON (cat_toys.cat_id = cats.id)
--     WHERE toys.price > 55 AND cats.color = 'Olive';

-- Paste your results below (as a comment):

-- ┌──────────┐
-- │ COUNT(*) │
-- ├──────────┤
-- │ 215      │
-- └──────────┘
-- Run Time: real 0.004 user 0.000000 sys 0.000000
-- QUERY PLAN
-- |--SCAN cat_toys
-- |--SEARCH toys USING INTEGER PRIMARY KEY (rowid=?)
-- `--SEARCH cats USING INTEGER PRIMARY KEY (rowid=?)


-- Analyze Results:

    -- Is the new index being applied in this query?

    -- I don't think I'm using the index right,
    -- the search time is not improving

-------------------------------------------------------------
-- Claude 3.5 Sonnet
-- You're correct in observing that the index you created on
-- cat_toys(toy_id) is not being utilized in this query. The
-- EXPLAIN QUERY PLAN output shows that cat_toys is still being
-- scanned, which indicates that the index is not being applied.

-- To improve this query's performance, we need to consider the
-- WHERE clause conditions and the join order. Here are some suggestions:

-- Create an index on cats(color) since we're filtering on this column:

-- CREATE INDEX idx_cats_color ON cats(color);

-- Create a composite index on toys(price, id) to cover both the
-- price condition and the join:

-- CREATE INDEX idx_toys_price_id ON toys(price, id);

-- Rewrite the query to start with the most restrictive condition:

-- EXPLAIN QUERY PLAN
-- SELECT COUNT(*) FROM cats
--     JOIN cat_toys ON (cats.id = cat_toys.cat_id)
--     JOIN toys ON (cat_toys.toy_id = toys.id)
--     WHERE cats.color = 'Olive' AND toys.price > 55;

-- After applying these changes, run the EXPLAIN QUERY PLAN again.
-- You should see the query using the indexes we've created, which
-- should improve the query's performance.

-- Remember, the effectiveness of indexes can vary based on the
-- data distribution and the specific query. It's always good to
-- test with your actual data and adjust as needed.
-------------------------------------------------------------

-- Find a count of `toys` records that have a price greater than
-- 55 and belong to a cat that has the color "Olive".

-- (NO INDEX YET)
EXPLAIN QUERY PLAN
SELECT * FROM cats
    JOIN cat_toys ON (cats.id = cat_toys.cat_id)
    JOIN toys ON (cat_toys.toy_id = toys.id)
    WHERE cats.color = 'Olive' AND toys.price > 55;
-- Run Time: real 0.109 user 0.000000 sys 0.000000
-- Run Time: real 0.132 user 0.000000 sys 0.015625
-- Run Time: real 0.089 user 0.000000 sys 0.000000
-- Run Time: real 0.090 user 0.000000 sys 0.015625
-- QUERY PLAN
--SCAN cat_toys
--SEARCH cats USING INTEGER PRIMARY KEY (rowid=?)
--SEARCH toys USING INTEGER PRIMARY KEY (rowid=?)

----------
-- Step 4 - Re-time the query using the new index

CREATE INDEX idx_cats_color ON cats(color);
CREATE INDEX idx_toys_price_id ON toys(price, id);

SELECT * FROM cats
    JOIN cat_toys ON (cats.id = cat_toys.cat_id)
    JOIN toys ON (cat_toys.toy_id = toys.id)
    WHERE cats.color = 'Olive' AND toys.price > 55;
Run Time: real 0.089 user 0.000000 sys 0.000000
Run Time: real 0.105 user 0.000000 sys 0.000000
Run Time: real 0.098 user 0.000000 sys 0.000000

-------------------------------------------------------------
Add an index on cat_toys:
CREATE INDEX idx_cat_toys_cat_id_toy_id ON cat_toys(cat_id, toy_id);

If you're only interested in the count, you could potentially optimize further:

-- EXPLAIN QUERY PLAN
-- SELECT COUNT(*)
-- FROM cats
-- WHERE color = 'Olive'
-- AND EXISTS (
--     SELECT 1
--     FROM cat_toys
--     JOIN toys ON cat_toys.toy_id = toys.id
--     WHERE cat_toys.cat_id = cats.id AND toys.price > 55
-- );
-------------------------------------------------------------

SELECT * FROM cats
    JOIN cat_toys ON (cats.id = cat_toys.cat_id)
    JOIN toys ON (cat_toys.toy_id = toys.id)
    WHERE cats.color = 'Olive' AND toys.price > 55;
-- Run Time: real 0.086 user 0.015625 sys 0.000000
-- Run Time: real 0.087 user 0.000000 sys 0.000000
-- Run Time: real 0.095 user 0.000000 sys 0.000000

EXPLAIN QUERY PLAN
SELECT COUNT(*) FROM cats
    JOIN cat_toys ON (cats.id = cat_toys.cat_id)
    JOIN toys ON (cat_toys.toy_id = toys.id)
    WHERE cats.color = 'Olive' AND toys.price > 55;
-- ┌──────────┐
-- │ COUNT(*) │
-- ├──────────┤
-- │ 215      │
-- └──────────┘
-- Run Time: real 0.001 user 0.000000 sys 0.000000

-- QUERY PLAN
--SEARCH cats USING COVERING INDEX idx_cats_color (color=?)
--SEARCH cat_toys USING COVERING INDEX idx_cat_toys_cat_id_toy_id (cat_id=?)
--SEARCH toys USING INTEGER PRIMARY KEY (rowid=?)







----------
-- Query (to be used in the sqlite CLI):

-- EXPLAIN QUERY PLAN



-- Paste your results below (as a comment):


-- Analyze Results:
    -- Are you still getting the correct query results?


    -- Did the execution time improve (decrease)?


    -- Do you see any other opportunities for making this query more efficient?



---------------------------------
-- Notes From Further Exploration
---------------------------------
