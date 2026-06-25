# Workspace Rules & Guidelines

## ⚠️ Git Actions and Workflows Management

### 1. Global Gitignore Bypass
The host machine has a global gitignore configuration (`~/.gitignore_global`) containing a rule (`.*`) that automatically ignores all dotfolders. This includes the `.github` directory.
- **Rule:** When modifying or creating GitHub Actions workflow files inside `.github/workflows/`, you **MUST** use force-add (`git add -f`) to stage and track them. Otherwise, they will not be committed or pushed, breaking scheduled cron scrapers.
- **Verification:** Always run `git status` or `git ls-files .github` to verify workflow files are tracked.

### 2. Environment Variables & Secrets
The legal update and cause list python scrapers rely on Supabase database connectivity.
- **Rule:** Any workflow configuration (such as `.github/workflows/scrape_cause_list.yml`) running these scrapers must have access to `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` in their workflow environment block (`env:`). Always map these variables from secrets.
