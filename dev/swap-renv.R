## Run this after "run-before-swap.R" and before "run-after-swap.R"

## This might not be "allowed", just for the sake of demonstrating
Sys.setenv(RENV_PATHS_LOCKFILE = "renv-upd-macpan.lock")
renv::restore()
## Restart R after running this, you'll be on most recent macpan2 version
