## Run this first
devtools::load_all()

default_model_simulator <- make_simulator("five-year-age-groups")
expected_output <- default_model_simulator$report()
saveRDS(expected_output, "dev/expected_output.RDS")
