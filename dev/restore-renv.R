## Run this to restore lock file after running "run-after-swap.R"
Sys.setenv(RENV_PATHS_LOCKFILE = "renv.lock")
renv::install()
## Then restart R again
