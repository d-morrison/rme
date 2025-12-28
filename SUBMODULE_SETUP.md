# LaTeX Macros Submodule Setup

## ✅ Setup Complete!

The LaTeX macros submodule has been successfully configured and is now tracking the remote repository at https://github.com/d-morrison/macros.git.

### Current Status

- ✅ Submodule URL: https://github.com/d-morrison/macros.git
- ✅ Submodule path: `latex-macros/`
- ✅ Current commit: 902bab8
- ✅ All 52 `.qmd` files updated to reference `latex-macros/macros.qmd`
- ✅ GitHub Actions workflows configured to checkout submodules

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
