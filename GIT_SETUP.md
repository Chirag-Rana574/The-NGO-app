# State Saving Guide - Git Setup

This guide will help you set up Git to save states of your NGO Medicine System app.

## What is State Saving?

State saving means tracking changes to your code over time so you can:
- 📸 Take "snapshots" of your work
- ⏮️ Go back to previous versions
- 🌿 Try new features without breaking what works
- 🤝 Collaborate with others
- ☁️ Backup your code to the cloud

## Quick Setup (5 minutes)

### Step 1: Initialize Git Repository

```bash
cd ~/Downloads/ngo-medicine-system
git init
```

This creates a hidden `.git` folder that tracks all changes.

### Step 2: Create .gitignore File

This tells Git which files to ignore (like passwords, temporary files, etc.):

```bash
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.venv

# Environment variables (IMPORTANT - contains passwords!)
.env
*.env
.env.local

# Node modules
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# React Native
.expo/
.expo-shared/
dist/
web-build/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Database
*.db
*.sqlite
*.sqlite3

# Logs
*.log
logs/

# Build files
build/
*.apk
*.ipa
EOF
```

### Step 3: Make Your First Commit (Save State)

```bash
# Add all files to staging
git add .

# Create your first snapshot
git commit -m "Initial commit: NGO Medicine System with patients/workers separation"
```

✅ **You've saved your first state!**

## Daily Workflow

### Save Your Work (Commit)

After making changes:

```bash
# Check what changed
git status

# Add specific files
git add mobile/src/screens/HomeScreen.tsx
git add backend/app/routers/patients.py

# Or add all changes
git add .

# Save the state with a message
git commit -m "Added dosage field to schedule creation"
```

### View History

```bash
# See all saved states
git log --oneline

# See what changed in last commit
git show

# See changes not yet committed
git diff
```

### Go Back to Previous State

```bash
# See all commits
git log --oneline

# Go back to a specific commit (copy the commit hash)
git checkout abc1234

# Return to latest
git checkout main
```

## Backup to Cloud (GitHub)

### Step 1: Create GitHub Account

1. Go to [github.com](https://github.com)
2. Sign up for free account
3. Verify your email

### Step 2: Create Repository on GitHub

1. Click "+" → "New repository"
2. Name it: `ngo-medicine-system`
3. Keep it **Private** (important for security!)
4. Don't initialize with README (you already have code)
5. Click "Create repository"

### Step 3: Connect Local to GitHub

GitHub will show you commands like:

```bash
cd ~/Downloads/ngo-medicine-system

# Add GitHub as remote
git remote add origin https://github.com/YOUR-USERNAME/ngo-medicine-system.git

# Rename branch to main (if needed)
git branch -M main

# Push your code to GitHub
git push -u origin main
```

### Step 4: Push Future Changes

After making commits:

```bash
git push
```

✅ **Your code is now backed up to the cloud!**

## Useful Git Commands

### Check Status
```bash
git status                    # See what changed
git log --oneline            # See commit history
git diff                     # See uncommitted changes
```

### Branching (Try New Features Safely)
```bash
git branch feature-sms       # Create new branch
git checkout feature-sms     # Switch to branch
# Make changes...
git add .
git commit -m "Added SMS notifications"
git checkout main            # Go back to main
git merge feature-sms        # Merge changes into main
```

### Undo Changes
```bash
git checkout -- filename.tsx  # Undo changes to file
git reset HEAD~1             # Undo last commit (keep changes)
git reset --hard HEAD~1      # Undo last commit (delete changes!)
```

### View Specific File History
```bash
git log -- mobile/src/screens/HomeScreen.tsx
git show abc1234:mobile/src/screens/HomeScreen.tsx
```

## Best Practices

### 1. Commit Often
- Commit after completing a feature
- Commit before trying something risky
- Commit at end of each work session

### 2. Write Good Commit Messages
```bash
# ❌ Bad
git commit -m "fixed stuff"

# ✅ Good
git commit -m "Fixed dosage validation in CreateScheduleScreen"
git commit -m "Added mobile_number field to workers table"
git commit -m "Updated home screen to 2x2 grid layout"
```

### 3. Never Commit Secrets
- ❌ Never commit `.env` files
- ❌ Never commit passwords or API keys
- ❌ Never commit database credentials
- ✅ Use `.gitignore` to exclude them

### 4. Pull Before Push (If Working with Others)
```bash
git pull    # Get latest changes
git push    # Upload your changes
```

## Common Scenarios

### Scenario 1: "I broke something, go back!"
```bash
# See recent commits
git log --oneline

# Go back to working version
git checkout abc1234

# If you want to make this permanent
git revert HEAD
```

### Scenario 2: "I want to try a new feature"
```bash
# Create and switch to new branch
git checkout -b feature-reports

# Make changes, commit them
git add .
git commit -m "Added patient reports feature"

# If it works, merge to main
git checkout main
git merge feature-reports

# If it doesn't work, just delete the branch
git branch -d feature-reports
```

### Scenario 3: "I accidentally committed .env file!"
```bash
# Remove from Git but keep local file
git rm --cached .env

# Add to .gitignore
echo ".env" >> .gitignore

# Commit the fix
git add .gitignore
git commit -m "Removed .env from tracking"

# If already pushed to GitHub, you need to:
# 1. Change all passwords in .env
# 2. Force push: git push --force
```

## Recommended Commit Schedule

### Daily
```bash
# End of day
git add .
git commit -m "End of day: [brief summary of what you did]"
git push
```

### After Each Feature
```bash
git add .
git commit -m "Implemented [feature name]"
git push
```

### Before Risky Changes
```bash
git add .
git commit -m "Checkpoint before refactoring authentication"
```

## GitHub Desktop (GUI Alternative)

If you prefer a visual interface:

1. Download [GitHub Desktop](https://desktop.github.com/)
2. Open your project folder
3. Use the GUI to:
   - See changes
   - Make commits
   - Push to GitHub
   - View history

## VS Code Integration

If you use VS Code:

1. Open project in VS Code
2. Click Source Control icon (left sidebar)
3. See changes, stage files, commit, push - all in the editor!

## Next Steps

1. ✅ Initialize Git: `git init`
2. ✅ Create `.gitignore`
3. ✅ Make first commit
4. ✅ Create GitHub account
5. ✅ Push to GitHub
6. 🔄 Commit regularly
7. 🔄 Push to GitHub daily

## Troubleshooting

### "Permission denied (publickey)"
Use HTTPS instead of SSH:
```bash
git remote set-url origin https://github.com/YOUR-USERNAME/ngo-medicine-system.git
```

### "Merge conflict"
```bash
# Open conflicted files, look for:
<<<<<<< HEAD
your changes
=======
their changes
>>>>>>> branch-name

# Edit to keep what you want, then:
git add .
git commit -m "Resolved merge conflict"
```

### "Detached HEAD state"
```bash
git checkout main
```

## Resources

- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [GitHub Guides](https://guides.github.com/)
- [Interactive Git Tutorial](https://learngitbranching.js.org/)

---

**Remember:** Git is like a time machine for your code. Use it often, and you'll never lose work again! 🚀
