test_that("get_model() returns a macpan2 model object", {
  model = get_model("old-and-young")
  expect_true("Model" %in% class(model))
})

test_that("get_model() returns a macpan2 model object (five-year-age-groups)", {
  model = get_model("five-year-age-groups")
  expect_true("TMBModelSpec" %in% class(model))
})

test_that("get_model() returns an expected snapshot for five-year-age-groups", {
  model = get_model("five-year-age-groups")
  expect_snapshot(model)
})
