# hackpkg

Analyzing and visualizing public transport accessibility in the **Romandie / Valais**
region of Switzerland, using the [search.ch timetable API](https://search.ch/timetable/api/).

*SUPSI — Data Science in R Hackathon, June 2026*
*Group 1: Alan Dominguez, Nathan Ferrari, Federico Lombardo, Francesco Masolini, Viktoria Kubisova, Maithili Nalawade*

---

## What it does

`hackpkg` downloads public transport connection data from the search.ch timetable
API, computes how long a traveler would have to wait for the next available
connection from **Lausanne** to each destination city at different times of day,
and produces a regional map where each city is coloured by its **median waiting
time** and sized by **population**.

The package covers the full pipeline from raw CSV data to the final map through
six exported functions, each handling one step.

---

## Installation

`hackpkg` is a development package, installed from source. From the project root,
in R:

```r
# install.packages("devtools")
devtools::install()
```

The package depends on `readr`, `dplyr`, `tidyr`, `rlang`, `httr`, `jsonlite`,
`sf`, and `ggplot2`. These are installed automatically.

---

## Setup and build

To regenerate documentation and build a distributable `.tar.gz` of the package:

```r
# Rebuild the man/ help pages and NAMESPACE from the roxygen comments
devtools::document()

# Verify the package (the two passing criteria: 0 errors, installs cleanly)
devtools::check(args = "--no-manual")
devtools::install()

# Build the distributable source tarball
devtools::build("path/to/r-hackathon")
# e.g. devtools::build("C:/Users/aland/Documents/hackpkg/r-hackathon")
```

`document()` and `check()` are local steps; the generated `man/` files and
`NAMESPACE` are committed alongside the `R/` source but never edited by hand.

---

## Dataset

The package bundles **`SwissCities.csv`** in `inst/extdata/`, accessible after
installation with `system.file("extdata", "SwissCities.csv", package = "hackpkg")`.

Each row is one city/station. The file covers four Swiss regions; `read_stations()`
filters to a single region by name.

| Column | Description |
|--------|-------------|
| `group_id` | Group number assigned to the region (1-4). |
| `region` | Region name, e.g. `"Romandie / Valais"`. |
| `is_origin` | `TRUE` for the region's single origin station, `FALSE` for destinations. |
| `city` | City name (used for labels and summaries). |
| `station_name` | Full station name as used by the timetable. |
| `station_id` | search.ch station ID, used for API calls (read as character). |
| `canton` | Canton abbreviation, e.g. `VD`, `VS` (used to highlight region boundaries). |
| `latitude` | Latitude (WGS84), used for map placement. |
| `longitude` | Longitude (WGS84), used for map placement. |
| `population` | City population, used for point size on the map. |

For Group 1, the origin is **Lausanne** (`8501120`) and there are 14 destination
cities across the Romandie / Valais region.

Swiss canton boundary shapefiles are bundled in `inst/extdata/boundaries/`,
accessible with `system.file("extdata", "boundaries", package = "hackpkg")`.

---

## How the project works

The data flows in a straight line through the six functions. Each takes a plain
data frame in and returns a plain data frame out, so every step can be inspected
on its own in the console.

```
SwissCities.csv
      |
      |  read_stations()         filter to the region
      v
  stations table
      |
      |  build_query_table()     all origin x destination x time combinations
      v
  query table  (70 rows: 1 origin x 14 destinations x 5 times)
      |
      |  get_routes_batch()      5 batch API calls (one per time slot) via the
      |                          one_to_many endpoint; results cached as .rds
      |                          reads each response from cache (no network)
      v
  raw API responses  (stored in cache/)
      |
      |  parse_routes()          flatten each response to one row per connection,
      |                          combined with dplyr::bind_rows()
      v
  all_routes table
      |
      |  compute_waiting_times() smallest wait per query, then median per destination
      v
  waiting_times table  (one row per destination city)
      |
      |  waiting_time_map()      ggplot2 map with canton boundaries
      v
  waiting-time accessibility map
```

---

## The functions

| Function | Purpose |
|----------|---------|
| `read_stations()` | Reads `SwissCities.csv` and filters to the group's region. Station IDs are read as character strings so they pass correctly to the API. |
| `build_query_table()` | Builds every origin-destination-time combination as a tidy query table that drives the download loop. |
| `get_routes_batch()` | Fetches routes for all destinations in a single request per time slot using the search.ch `one_to_many` endpoint (5 API calls instead of 70).|
| `parse_routes()` | Flattens one raw API response into a tidy data frame, one row per connection. |
| `compute_waiting_times()` | For each query keeps the smallest non-negative wait, then summarises the median wait per destination. |
| `waiting_time_map()` | Produces the regional waiting-time map: canton boundaries, destinations coloured by median wait and sized by population, origin marked with a star. |

---

## Example usage

Install the package first (see Installation above), then run the bundled
workflow in one line:

```r
source(system.file("example_workflow.R", package = "hackpkg"))
```

This script handles the full pipeline: reading stations, fetching routes via
`get_routes_batch()` (5 API calls total), parsing connections, computing
waiting times, and saving the map as `waiting_time_map.png` in the working
directory.

---

## Key design choices

**Minimal API calls with batch fetching.** `get_routes_batch()` uses the
search.ch `one_to_many` endpoint to retrieve all 14 destinations in a single
request per time slot, reducing the total from 70 individual calls to 5. Each
result is saved to `cache/` as a named `.rds` file (filename encodes origin,
destination, date, and time).

**Flat function interfaces.** Every function takes and returns plain data frames,
with no wrapper classes or shared state. Each step is independently testable and
easy to inspect.

**Waiting time as a median.** A single query time could land on an unusually good
or bad connection. Using five query times spread across the day and summarising
with the median gives a representative picture of each destination's accessibility.

**`.data$col` in dplyr pipelines.** All column references inside package functions
use the `.data` pronoun (from `rlang`) so that `R CMD check` does not raise
"no visible binding for global variable" warnings.

---

## Check and submission

The package passes `devtools::check(args = "--no-manual")` with **0 errors and
0 warnings**, and `devtools::install()` completes without error - the two criteria
for a passing grade.