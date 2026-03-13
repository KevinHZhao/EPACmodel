test_that("simulate() returns output and format is consistent", {
  simulator = make_simulator(model.name = "old-and-young")
  sim = simulate(simulator)
  expect_true(!is.null(sim))
  expect_equal(names(sim), c("time", "age_group", "variable_name", "value_type", "value"))
})

test_that("simulate() returns output and format is consistent (five-year-age-groups)", {
  simulator = make_simulator(model.name = "five-year-age-groups")
  sim = simulate(simulator)
  expect_true(!is.null(sim))
  expect_equal(names(sim), c("time", "age_group", "variable_name", "value_type", "value"))
})

test_that("simulate() returns expected snapshot for default five-year-age-groups", {
  simulator = make_simulator(model.name = "five-year-age-groups")
  expect_snapshot(simulate(simulator))
})

test_that("simulate() returns expected snapshot for five-year-age-groups with change-contacts", {
  simulator = make_simulator(model.name = "five-year-age-groups", scenario.name = "change-contacts")
  expect_snapshot(simulate(simulator))
})

test_that("simulate() returns expected snapshot for default hosp", {
  simulator = make_simulator(model.name = "hosp")
  expect_snapshot(simulate(simulator))
})

test_that("simulate() returns expected snapshot for hosp with change-contacts", {
  simulator = make_simulator(model.name = "hosp", scenario.name = "change-contacts")
  expect_snapshot(simulate(simulator))
})

test_that("simulate() updates hosp simulator state variables properly",{
  simulator = make_simulator(model.name = "hosp", scenario.name = "change-contacts")
  values = get_default_values("hosp")
  values_state <- values
  values_state$state["S.lb10"] <- 0
  hosp_mod <- simulate(make_simulator("hosp"), values = values_state)
  expect_equal(hosp_mod |> dplyr::filter(variable_name == "S", age_group == 10) |> dplyr::pull(value), rep(0, 61))
})

test_that("simulate() updates hosp simulator contact pars properly",{
  load(test_path("testdata", "expected_outputs.RData"))
  simulator = make_simulator(model.name = "hosp", scenario.name = "change-contacts")
  values = get_default_values("hosp")
  values_contact <- values
  values_contact$setting.weight <- c(school = 1, work = 1, household = 1, community = 1)
  hosp_mod <- simulate(make_simulator("hosp", values = list(time.steps = 365)), values = values_contact) |>
    dplyr::filter(value_type == "state")

  expected_tidy <- tidy_output(expected_hosp_contact_mod) |>
    dplyr::rename(age_group = age, variable_name = var) |>
    dplyr::select(time, age_group, variable_name, value_type, value) |>
    dplyr::filter(value_type == "state", time != 366) |>
    dplyr::mutate(age_group = as.integer(age_group))

  compare <- dplyr::left_join(expected_tidy, hosp_mod, by = c("time", "age_group", "variable_name", "value_type"))
  expect_equal(compare$value.x, compare$value.y)
})

test_that("simulate() updates hosp simulator transmission and flow variables properly",{
  simulator = make_simulator(model.name = "hosp", scenario.name = "change-contacts")
  values = get_default_values("hosp")
  values_flow <- values
  values_flow$flow <- calculate_flow("hosp", values_flow)
  values_flow$flow[grepl("progression", names(values_flow$flow))] <- 0
  values_flow$transmissibility <- 0
  hosp_mod <- simulate(make_simulator("hosp"), values = values_flow)
  expect_equal(hosp_mod |> dplyr::filter(variable_name == "E") |> dplyr::pull(value), rep(1, 61 * 17))
})

test_that("simulate() for hosp in change-contacts is consistent with old implementation",{
  load(test_path("testdata", "expected_outputs.RData"))
  simulator = make_simulator(model.name = "hosp", scenario.name = "change-contacts")
  hosp <- simulate(simulator) |>
    dplyr::filter(value_type == "state")

  expected_tidy <- tidy_output(expected_hosp_output_change) |>
    dplyr::rename(age_group = age, variable_name = var) |>
    dplyr::select(time, age_group, variable_name, value_type, value) |>
    dplyr::filter(value_type == "state", time != 61) |>
    dplyr::mutate(age_group = as.integer(age_group))

  compare <- dplyr::left_join(expected_tidy, hosp, by = c("time", "age_group", "variable_name", "value_type"))
  expect_equal(compare$value.x, compare$value.y)
})

test_that("simulate() for five-year-age-groups in change-contacts is consistent with old implementation",{
  load(test_path("testdata", "expected_outputs.RData"))
  simulator = make_simulator(model.name = "five-year-age-groups", scenario.name = "change-contacts")
  five <- simulate(simulator) |>
    dplyr::filter(value_type == "state")

  expected_tidy <- tidy_output(expected_five_output_change) |>
    dplyr::rename(age_group = age, variable_name = var) |>
    dplyr::select(time, age_group, variable_name, value_type, value) |>
    dplyr::filter(value_type == "state", time != 61) |>
    dplyr::mutate(age_group = as.integer(age_group))

  compare <- dplyr::left_join(expected_tidy, five, by = c("time", "age_group", "variable_name", "value_type"))
  expect_equal(compare$value.x, compare$value.y)
})

test_that("simulate() for old-and-young in change-transmission is consistent with old implementation",{
  load(test_path("testdata", "expected_outputs.RData"))
  simulator = make_simulator(model.name = "old-and-young", scenario.name = "change-transmission")
  oy <- simulate(simulator) |>
    dplyr::filter(value_type == "state")

  tidy_output_yo = function(output){
    output <- (output
               # parse state names
               |> tidyr::separate(
                 state_name,
                 into = c("var", "age"),
                 sep = "_"
               )
               # enforce order of states
               |> dplyr::mutate(
                 var = forcats::as_factor(var)
               )
    )

    output
  }

  expected_tidy <- tidy_output_yo(expected_oy_output_change) |>
    dplyr::rename(age_group = age, variable_name = var) |>
    dplyr::select(time, age_group, variable_name, value_type, value) |>
    dplyr::filter(value_type == "state", time != 151)

  compare <- dplyr::left_join(expected_tidy, oy, by = c("time", "age_group", "variable_name", "value_type"))
  expect_equal(compare$value.x, compare$value.y)
})
