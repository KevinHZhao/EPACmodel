#' Construct a simulator for a model
#'
#' @template param_model.name
#' @param scenario.name Optional. Name of scenario to simulate. See README for `model.name` for options. If NULL, use base model.
#' @param values Optional. List containing updates to variables + values used to initialize the model simulator. If NULL, use default list is read from disk and used as is.
#' @param output_flows Optional. Vector of flows to output, use [list_flows()] to obtain a list of all flows for the given model.
#' @template param_local
#'
#' @return A `TMB::TMBSimulator` object created by the [macpan2::mp_simulator()]
#' function, with additional `agelabs` and `model.name`
#' component appended, containing the labels of age groups and the model name
#' @export
make_simulator <- function(
  model.name,
  scenario.name = NULL,
  values = NULL,
  output_flows = NULL,
  local = FALSE
){
  if(!all(output_flows %in% list_flows(model.name))){
    stop("output_flows contains non-flow variable names.\n")
  }

  # Convert NULL scenario.name to empty string to make if statements cleaner
  if(is.null(scenario.name)) scenario.name = ""

  # Load model
  model = get_model(model.name, local = local)

  # Source helpers, if need be
  helpers.file.name = get_model_path(
    model.name = NULL,
    file.name = paste0("helpers_", model.name, ".R"),
    dir.name = "R",
    local = local
  )
  if(!is.null(helpers.file.name)){
    eval(parse(text = readLines(
      helpers.file.name
    )))
  }

  # Get default values required to initialize model simulator + make model
  # modifications
  updated.values = values
  values = get_default_values(model.name, local = local)

  # Update values from default, as requested
  if(!is.null(updated.values)){
    names.to.replace = intersect(names(updated.values), names(values))

    for(name in names.to.replace){
      values[[name]] = updated.values[[name]]
    }
  }

  # Expressions to run before initializing the simulator, if present
  before.sim.file.name = get_model_path(
    model.name = model.name,
    file.name = "run-before-simulator.R",
    local = local
  )
  if(!is.null(before.sim.file.name)){
    eval(parse(text = readLines(
      before.sim.file.name
    )))
  }

  # Load in simulator expression and evaluate
  model_simulator = eval(parse(text = readLines(
    get_model_path(
      model.name = model.name,
      file.name = "simulator-expression.R",
      local = local
    )
  )))

  # Expressions to run after initializing simulator (model modifications), if
  # present
  after.sim.file.name = get_model_path(
    model.name = model.name,
    file.name = "run-after-simulator.R",
    local = local
  )
  if(!is.null(after.sim.file.name)){
    eval(parse(text = readLines(
      after.sim.file.name
    )))
  }

  model_simulator$agelabs <- agelabs # add agelabs to the simulator for simulate()
  model_simulator$model.name <- model.name # add model name to the simulator for simulate()

  return(model_simulator)
}
