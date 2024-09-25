----------
-- Step 0 - Create a Query
----------
-- Query: Find a count of `toys` records that have a price greater than
    -- 55 and belong to a cat that has the color "Olive".

    -- SELECT toys.id, toys.name, toys.price FROM toys
    -- SELECT * FROM toys
    -- EXPLAIN QUERY PLAN
    SELECT COUNT(*) FROM toys
        JOIN cat_toys ON (toys.id = cat_toys.toy_id)
        JOIN cats ON (cat_toys.cat_id = cats.id)
        WHERE toys.price > 55 AND cats.color = 'Olive';
        -- LIMIT 15;

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

CREATE INDEX idx_toy_id ON cat_toys(toy_id);

-- Analyze Query:
EXPLAIN QUERY PLAN
SELECT COUNT(*) FROM toys
    JOIN cat_toys ON (toys.id = cat_toys.toy_id)
    JOIN cats ON (cat_toys.cat_id = cats.id)
    WHERE toys.price > 55 AND cats.color = 'Olive';

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
    -- the time is the same before and after



----------
-- Step 4 - Re-time the query using the new index
----------
-- Query (to be used in the sqlite CLI):

    -- Your code here

-- Paste your results below (as a comment):


-- Analyze Results:
    -- Are you still getting the correct query results?


    -- Did the execution time improve (decrease)?


    -- Do you see any other opportunities for making this query more efficient?



---------------------------------
-- Notes From Further Exploration
---------------------------------
