# simulator-expression.R
states <- c(
  "S",
  "E",
  "R",
  "H",
  "I",
  "D"
)

age_over <- c(
  states,
  "N",
  "prog",
  "rec",
  "hosp",
  "disch",
  "d_H",
  "d_I",
  "infect"
) # Epi variables to stratify by age over

age.group.lower <- c("y", "o") # Similar to 5 year age groups, just modified
nage <- length(age.group.lower)
agelabs <- age.group.lower

extract_dot <- function(v, var){
  return(unname(v[grepl(paste0("^",var,"\\_"), names(v))])) # Using _ instead of .
}

N <- rep(0, nage)
for (i in states){
  N <- N + extract_dot(values$state, i)
}

## Have to build matrix manually
contact. <- matrix(
  c(
    values$params[["c_yy"]],
    values$params[["c_oy"]],
    values$params[["c_yo"]],
    values$params[["c_yy"]]
  ),
  nrow = 2
)

default <-
  with(values,
       list(
         transmission = extract_dot(params, "transmission"),
         progression = extract_dot(params, "progression"),
         hospitalization = extract_dot(params, "hospitalization"),
         discharge = extract_dot(params, "discharge"),
         recovery = extract_dot(params, "recovery"),
         death_H = extract_dot(params, "deathH"),
         death_I = extract_dot(params, "deathI"),
         contact. = contact.
       )
  )

inits <-
  with(values,
       list(
         S = extract_dot(state, "S"),
         E = extract_dot(state, "E"),
         I = extract_dot(state, "I"),
         H = extract_dot(state, "H"),
         R = extract_dot(state, "R"),
         D = extract_dot(state, "D")
       )
  )

## This used to be done after making the simulator but to use modern macpan2
## functions requires modifying the model not the simulator
expr <- list()
ints <- list()
if(scenario.name == "change-transmission"){
  # modifications to the base model to incorporate time-varying, age-based interventions

  trans_times <- c(0, values$intervention.day) # time of interventions
  # need to include initial day, even though that's not technically
  # an intervention day
  transval_o <- values$params[["transmission_o"]]
  transfactors_o <- c(1, values$trans.factor.old) # multiple of transmission rate for old
  transvec_o <- transval_o*transfactors_o

  transval_y <- values$params[["transmission_y"]]
  transfactors_y <- c(1, values$trans.factor.young) # multiple of transmission rate for young
  transvec_y <- transval_y*transfactors_y

  default <- append(
    default,
    list(
      transmission_y_values = transvec_y,
      transmission_o_values = transvec_o
    )
  )

  ints <- list(
    transmission_o_changepoints = trans_times,
    transmission_y_changepoints = trans_times
  )

  expr <- list(
    transmission ~ c(time_var(transmission_y_values, transmission_y_changepoints),
                     time_var(transmission_o_values, transmission_o_changepoints))
  )
}

model_simulator <-
  model |>
  macpan2::mp_tmb_insert(
    phase = "during",
    expressions = expr,
    default = default,
    inits = inits,
    integers = ints
  ) |>
  macpan2::mp_simulator(
    time_steps = values$time.steps,
    outputs = c(states, output_flows) # This can be changed to for example, age_over to get more of the values for debugging
  )

model_simulator
