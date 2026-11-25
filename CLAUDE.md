# Staffing & Schedule Planner

Bancroft Construction's shared staffing planner: who works on which job each month, site
supervisor (SS) and project manager (PM) coverage, utilization, and contract dollars per person.

- Live site: https://bancroft-construction.github.io/staffing-planner/
- Hosting: GitHub Pages, published from the `main` branch. A push to `main` goes live within
  a minute or two, so there is no separate staging copy.

## How it is built

- The whole app is one file, `index.html`: HTML, CSS and plain ES5 JavaScript inside a single IIFE.
  There is no build step and no package manager.
- Data lives in Supabase (`SUPABASE_URL` / `SUPABASE_KEY` near the top of the script). The whole plan
  is one JSON document: table `plan`, row `id = 1`, column `data`. Saved versions for the History tab
  are stored there too. Edits sync between people live through the Supabase Realtime channel `plan-live`.
- The entry screen asks for a name and the team passcode (`PASSCODE` in the script). That check runs
  in the browser only, and the passcode is visible to anyone who reads the page source.

## Tabs

Assignments, Schedule & Coverage, Utilization & People (Carpentry staff are listed last, without
color bands), Contract $, History.

## Exports

- **Export CSV** exports the current tab.
- **Export for Schedule Board** downloads `schedule-board.csv` (Project, Category, Contract, OH&P %,
  Start, End) for every non-overhead job across all months. The Jobsite Schedule Board reads this file
  with its **Import from planner** button, so keep those column names unchanged.

## Working on it

- Edit `index.html`, open it in a browser to check it, then commit and push to `main`.
- Do not change the shape of the saved JSON without handling older saved data (`ensureShape`),
  because the same document is shared by everyone and by saved versions.
- If the page says the plan database isn't responding, the free Supabase project has probably paused
  after a week without use: restore it from the Supabase dashboard.

## Brand colors and chart colors

The page uses the Bancroft brand palette (Marble #FFFCFA, Stone #E7E3DD, Copper #8A5D3B, Granite #252928) in
the `:root` variables. The Schedule & Coverage and Utilization panels are the exception: CSS scoped to
`#view-sched` and `#view-util` keeps them white with traditional colors (green active/well utilized, red
gaps, amber off-schedule/light, blue SS, purple PM) in light and dark mode.
