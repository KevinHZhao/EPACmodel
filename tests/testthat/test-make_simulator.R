test_that("simulator is initialized for model that doesn't have helper functions", {
  expect_true("TMBSimulator" %in% class(make_simulator(model.name = "old-and-young")))
})

test_that("simulator is initialized for model that has functions", {
  expect_true("TMBSimulator" %in% class(make_simulator(model.name = "five-year-age-groups")))
})

test_that("value gets updated from default", {
  values = get_default_values("five-year-age-groups")
  values$transmissibility = 0

  expect_true(
    all(
    make_simulator(
      model.name = "five-year-age-groups",
      values = values)$tmb_model$data_arg()$mats[[1]] == 0 ## Used to be mats[[3]], transmission seems to have moved to [[1]]
    )
  )
})

test_that("simulator from five-year-age-groups snapshot is consistent", {
  expect_snapshot(make_simulator("five-year-age-groups"))
})

test_that("simulator from five-year-age-groups with change-contacts snapshot is consistent", {
  expect_snapshot(make_simulator("five-year-age-groups", "change-contacts"))
})
