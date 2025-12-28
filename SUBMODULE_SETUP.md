# LaTeX Macros Submodule Setup Instructions

The LaTeX macros have been extracted from this repository into a separate repository to be used as a git submodule.

## Setup Steps Required

### 1. Create the GitHub Repository

You need to create a new GitHub repository named `rme-latex-macros` under your account (`d-morrison`).

1. Go to https://github.com/new
2. Create a repository named `rme-latex-macros`
3. Do NOT initialize it with a README (we already have content)

### 2. Push the Macros Repository

The macros have been prepared in the `latex-macros/` directory with their own git history. Push this to GitHub:

```bash
cd latex-macros
git remote add origin https://github.com/d-morrison/rme-latex-macros.git
git branch -M main  # Optional: rename master to main
git push -u origin main  # or master if you kept that branch name
cd ..
```

### 3. Initialize the Submodule

After pushing the macros repository, initialize it as a proper submodule in the main repository:

```bash
# The .gitmodules file has already been created and configured
git add .gitmodules
git add latex-macros
git commit -m "Add latex-macros as a submodule"
```

## What Has Been Done

- ✅ Created `latex-macros/` directory with macros.qmd and README.md
- ✅ Initialized it as a git repository with an initial commit
- ✅ Created `.gitmodules` file pointing to `https://github.com/d-morrison/rme-latex-macros.git`
- ✅ Updated all 52 `.qmd` files to reference `latex-macros/macros.qmd` instead of `macros.qmd`
- ✅ Removed the old `macros.qmd` file from the root directory

## For Future Clones

After the submodule is properly set up on GitHub, others cloning this repository should run:

```bash
git clone --recurse-submodules https://github.com/d-morrison/rme.git
```

Or if already cloned:

```bash
git submodule update --init --recursive
```

## Updating the Macros

To update the macros in the future:

```bash
cd latex-macros
# Make changes to macros.qmd
git add macros.qmd
git commit -m "Update macros"
git push
cd ..
git add latex-macros  # Update the submodule reference
git commit -m "Update latex-macros submodule"
git push
```
