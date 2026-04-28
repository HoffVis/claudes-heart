# Heart Tasks — Watcher

## Config
- interval: immediate
- mode: watcher
- max_iterations: 0

## Tasks

## Improvement Loops
- [ ] Run the project build — if errors, add fix tasks to ## Tasks with specific file paths and error messages
- [ ] Run the project tests — if failures, add fix tasks with test names and failure reasons
- [ ] Check for outdated dependencies (npm outdated / pip list --outdated / cargo outdated) — if any major versions behind, add upgrade tasks
- [ ] Review the last 5 git commits for code quality issues — large files, missing tests, inconsistent naming. Add improvement tasks if patterns emerge.
- [ ] Check for security issues (npm audit / pip-audit / cargo audit) — if vulnerabilities found, add fix tasks with severity and affected packages
