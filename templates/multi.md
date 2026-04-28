# Heart Tasks — Orchestrator

## Config
- interval: immediate
- mode: orchestrator
- max_iterations: 0

## Projects
<!-- List sub-projects with paths to their HEART.md files -->
<!-- - project-name: ./path/to/HEART.md                   -->

## Dependencies
<!-- Track cross-project dependencies -->
<!-- - project-a depends on project-b (reason)            -->

## Tasks

## Improvement Loops
- [ ] Scan all sub-project HEART.md files listed in ## Projects. For each, count incomplete tasks and assess priority. Pick the highest-impact task across all projects and execute it. Respect ## Dependencies — don't start downstream work if an upstream dependency has pending tasks that would affect it.
- [ ] Run builds in all sub-projects. If a change in one project breaks another, add a fix task to the broken project's HEART.md with the specific error and which upstream change caused it.
- [ ] Check for cross-project consistency — shared types, API contracts, version alignment. If projects have drifted, add alignment tasks.
