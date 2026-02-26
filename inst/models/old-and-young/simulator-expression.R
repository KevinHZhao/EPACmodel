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

age.group.lower <- c("y", "o") # SImilar to 5 year age groups, just modified
nage <- length(age.group.lower)
agelabs <- age.group.lower

extract_dot <- function(v, var){
  return(v[grepl(paste0("^",var,"\\_"), names(v))]) # Using _ instead of .
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

model_simulator <-
  model |>
  macpan2::mp_tmb_insert(
    default = default,
    inits = inits
  ) |>
  macpan2::mp_simulator(
    time_steps = values$time.steps,
    outputs = c(states) # This can be changed to for example, age_over to get more of the values for debugging
  )
