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

  if (!is.null(values)) {
    message("Updating simulator values in `simulate` only supported for the `hosp`, and `hosp-treat` models currently.")
    # This should work for hosp-treat too
    # sim with new input values

    # recalculate contact parameters
    values$contact.pars <- mk_contact_pars(
      age.group.lower = seq(0, 80, by = 5),
      setting.weight = values$setting.weight,
      pop.new = values$pop
    )

    # allow user to pass flow directly and avoid recalculation from
    # epi parameters (_e.g._ if tailoring certain params by age)
    if ("flow" %in% names(values)) {
      warning("ignoring epi parameters for flows in `values` and using `values$flow` directly")
      if (is.null(names(values$flow))){
        stop("values$flow must be named.\n")
      }
      flow <- values$flow
    } else {
      # recalculate flow
      flow <- calculate_flow(simulator$model.name, values)
    }

    transmission <- calculate_transmission(simulator$model.name, values)

    mat_to_df <- function(m, name) {
      colnames(m) <- 0:(ncol(m) - 1)
      rownames(m) <- 0:(nrow(m) - 1)
      m_df <- expand.grid(row = as.integer(rownames(m)), col = as.integer(colnames(m))) |>
        dplyr::mutate(value = as.vector(m), mat = name) |>
        dplyr::select(mat, row, col, value)
      return(m_df)
    }

    contact <- values$contact.pars$p.mat
    contact_df <- mat_to_df(contact, "contact.")

    params_to_fit <-
      tibble::enframe(
        c(values$state, flow), name = "tmp", value = "value"
      ) |>
      tidyr::separate(tmp, into = c("mat", "age"), sep = "\\.lb") |>
      dplyr::mutate(col = 0, row = as.integer(age)/5) |>
      dplyr::select(mat, row, col, value, -age) |>
      dplyr::add_row(mat = "transmission", row = 0:(length(transmission) - 1), col = 0, value = transmission) |>
      rbind(contact_df)

    # if "contact_changepoints" is in mats
    # this model has parameters for the change-contacts scenario
    # in its parameters frame, so we should refresh
    # and attach these values as well (otherwise we will have the wrong length in our pvec)
    mats <- unique(simulator$matrix_names()) # params_frame()... doesn't seem to work anymore, not sure if this breaks anything

    if("contact_changepoints" %in% mats){
      # recalculate new contact parameters
      values$contact.pars.new <- mk_contact_pars(
        age.group.lower = seq(0, 80, by = 5),
        setting.weight = values$setting.weight.new,
        pop.new = values$pop
      )

      contact_changepoints <- calculate_contact_changepoints(values)
      contact_values <- calculate_contact_values(values)
      contact_values_df <- mat_to_df(contact_values, "contact_values")
      transmission_values <- calculate_transmission_values(values)
      transmission_values_df <- mat_to_df(transmission_values, "transmission_values")

      params_to_fit <- params_to_fit |>
        dplyr::add_row(mat = "contact_changepoints", row = 0:(length(contact_changepoints) - 1), col = 0, value = contact_changepoints) |>
        rbind(contact_values_df) |>
        rbind(transmission_values_df)
    }

    simulator$replace$params_frame(params_to_fit) # moved params frame to simulate instead of simulator expression
    # this now raises a warning from tmb, i think it's because we're updating state variables, but should still work as expected
  }
  sim = macpan2::mp_trajectory(simulator, include_initial = TRUE) ## should properly capture changes to params frame now

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
