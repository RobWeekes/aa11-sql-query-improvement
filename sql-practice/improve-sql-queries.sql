----------
-- Step 0 - Create a Query
----------
-- Query: Select all cats that have a toy with an id of 5

EXPLAIN QUERY PLAN
SELECT * FROM cats
    JOIN cat_toys ON (cats.id = cat_toys.cat_id)
    WHERE cat_toys.toy_id = 5;
    -- LIMIT 30;

-- Paste your results below (as a comment):
-- ┌──────┬─────────┬──────────┬────────────┬───────┬────────┬────────┐
-- │  id  │  name   │  color   │   breed    │  id   │ cat_id │ toy_id │
-- ├──────┼─────────┼──────────┼────────────┼───────┼────────┼────────┤
-- │ 4002 │ Rachele │ Maroon   │ Foldex Cat │ 4509  │ 4002   │ 5      │
-- │ 31   │ Rodger  │ Lavender │ Oregon Rex │ 10008 │ 31     │ 5      │
-- │ 77   │ Jamal   │ Orange   │ Sam Sawet  │ 10051 │ 77     │ 5      │
-- └──────┴─────────┴──────────┴────────────┴───────┴────────┴────────┘



----------
-- Step 1 - Analyze the Query
----------
-- Query:

-- SELECT * FROM cats
--     JOIN cat_toys ON (cats.id = cat_toys.cat_id)
--     WHERE cat_toys.toy_id = 5;

-- Paste your results below (as a comment):

-- What do your results mean?

    -- Was this a SEARCH or SCAN?

    -- EXPLAIN QUERY PLAN <QUERY>
    --SCAN cat_toys
    --SEARCH cats USING INTEGER PRIMARY KEY (rowid=?)

    -- What does that mean?

    -- it looked through every record (row) of cat_toys for id's of 5,
    -- then it searched for the corresponding indexed cat rows matching the cat_toys id


----------
-- Step 2 - Time the Query to get a baseline
----------
-- Query (to be used in the sqlite CLI):

-- .timer ON

-- SELECT * FROM cats
--     JOIN cat_toys ON (cats.id = cat_toys.cat_id)
--     WHERE cat_toys.toy_id = 5;

-- Paste your results below (as a comment):

-- ┌──────┬─────────┬──────────┬────────────┬───────┬────────┬────────┐
-- │  id  │  name   │  color   │   breed    │  id   │ cat_id │ toy_id │
-- ├──────┼─────────┼──────────┼────────────┼───────┼────────┼────────┤
-- │ 4002 │ Rachele │ Maroon   │ Foldex Cat │ 4509  │ 4002   │ 5      │
-- │ 31   │ Rodger  │ Lavender │ Oregon Rex │ 10008 │ 31     │ 5      │
-- │ 77   │ Jamal   │ Orange   │ Sam Sawet  │ 10051 │ 77     │ 5      │
-- └──────┴─────────┴──────────┴────────────┴───────┴────────┴────────┘
-- Run Time: real 0.003 user 0.000000 sys 0.000000



----------
-- Step 3 - Add an index and analyze how the query is executing
----------

-- Create index:

    -- CREATE INDEX idx_toy_id ON cat_toys(toy_id);

-- Analyze Query:

    -- QUERY PLAN
|--SEARCH cat_toys USING INDEX idx_toy_id (toy_id=?)
`--SEARCH cats USING INTEGER PRIMARY KEY (rowid=?)
-- Run Time: real 0.000 user 0.000000 sys 0.000000

-- Analyze Results:

    -- Is the new index being applied in this query?

-- Yes, it says SEARCH cat_toys USING INDEX idx_toy_id


----------
-- Step 4 - Re-time the query using the new index
----------
-- Query (to be used in the sqlite CLI):

EXPLAIN QUERY PLAN

SELECT * FROM cats
    JOIN cat_toys ON (cats.id = cat_toys.cat_id)
    WHERE cat_toys.toy_id = 5;

-- Paste your results below (as a comment):


-- Analyze Results:
    -- Are you still getting the correct query results?
    -- Yes

    -- Did the execution time improve (decrease)?
    -- Improved slightly, from .003 to .002 (repeatedly) and .001 (once)


    -- I had to prevent SQLite from caching query results to see the difference.
    -- One effective method is to use the "PRAGMA" statement to modify SQLite's behavior.
    -- You can try the following:

    -- Before running your query, execute:
    --     PRAGMA cache_size = 0;
    --     PRAGMA temp_store = MEMORY;

    -- After your query, you can clear the cache with:
    --     PRAGMA cache_size = -2000;


    -- Do you see any other opportunities for making this query more efficient?


---------------------------------
-- Notes From Further Exploration
---------------------------------
