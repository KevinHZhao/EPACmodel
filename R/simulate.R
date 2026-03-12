#' Simulate from a simulator
#'
#' @param simulator Simulator object, initialized using [make_simulator()]
#' @param values Complete list of model values to update the model simulator before generating the simulation. Must match format of `params` list from default (output of [get_default_values()] for desired model). If `NULL`, use values as currently attached to the model simulator.
#'
#' @return A data frame containing simulation results with columns
#'  - `time`: time in days from simulation start
#'  - `age_group`: age group label of relevant state/flow variable (0 if not an
#'   age structured variable)
#'  - `variable_name`: name of state/flow variable (e.g., "S")
#'  - `value_type`: type of values, such as `state` (count of individuals in a compartment) and `flow` (flows between compartments)
#'  - `value`
#' @export
simulate <- function(simulator, values = NULL) {

  if (is.null(values)) {
    sim = macpan2::mp_trajectory(simulator, include_initial = TRUE) ## only this part updated
  } else {
    message("Updating simulator values in `simulate` only supported for the `hosp` model currently.")
    # sim with new input values
    mats <- unique(simulator$matrix_names()) # params_frame()... doesn't seem to work anymore, not sure if this breaks anything
    pvec = make_pvec(values, mats)
    sim = simulator$report(pvec)
  }

  # reformat output
  data.frame(
    time = sim$time,
    age_group = simulator$agelabs[sim$row + 1], # convert row to relevant age label
    variable_name = forcats::as_factor(sim$matrix) # enforce order of states
  ) |>
    dplyr::mutate(
      value_type = ifelse(variable_name %in% list_flows(simulator$model.name), "flow", "state"),
      value = sim$value
    )
}
