test_that("simulate() returns output and format is consistent", {
  simulator = make_simulator(model.name = "old-and-young")
  sim = simulate(simulator)
  expect_true(!is.null(sim))
  expect_equal(names(sim), c("time", "state_name", "value_type", "value"))
})

test_that("simulate() returns output and format is consistent (five-year-age-groups)", {
  simulator = make_simulator(model.name = "five-year-age-groups")
  sim = simulate(simulator)
  expect_true(!is.null(sim))
  expect_equal(names(sim), c("time", "state_name", "value_type", "value"))
})

test_that("simulate() returns expected snapshot for default five-year-age-groups", {
  simulator = make_simulator(model.name = "five-year-age-groups")
  expect_snapshot(simulate(simulator))
})

test_that("simulate() returns expected snapshot for five-year-age-groups with change-contacts", {
  simulator = make_simulator(model.name = "five-year-age-groups", scenario.name = "change-contacts")
  expect_snapshot(simulate(simulator))
})
