age_over <- c(
  "S",
  "E",
  "R",
  "H",
  "I",
  "D",
  "N",
  "prog",
  "rec",
  "hosp",
  "disch",
  "d_H",
  "d_I",
  "infect"
) # Epi variables to stratify by age over

nage <- length(age.group.lower)
agelabs <- paste0("lb", age.group.lower)

extract_dot <- function(v, var){
  return(v[grepl(paste0("^",var,"\\."), names(v))])
}

N <- rep(0, nage)
for (i in age_over[1:6]){
  N <- N + extract_dot(values$state, i)
}

default <-
  with(values,
       list(
         transmission = transmission,
         progression = extract_dot(flow, "progression"),
         hospitalization = extract_dot(flow, "hospitalization"),
         discharge = extract_dot(flow, "discharge"),
         recovery = extract_dot(flow, "recovery"),
         death_H = extract_dot(flow, "death_H"),
         death_I = extract_dot(flow, "death_I"),
         contact. = contact.pars.initial$p.mat
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
    outputs = c(age_over)
  )
