values <- readRDS("inst/models/five-year-age-groups/default_values.rds")

nage <- length(age.group.lower)
agelabs <- paste0("lb", age.group.lower)

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

computations <- list(
  N ~ S + E + I + H + R + D, # Vector addition (no sum)
)

flows <- list(
  scaled_infected ~ I * transmission / N,
  mp_per_capita_flow("S", "E", "contact. %*% scaled_infected", "infect"),
  mp_per_capita_flow("E", "I", "progression", "prog"),
  mp_per_capita_flow("I", "H", "hospitalization", "hosp"),
  mp_per_capita_flow("H", "R", "discharge", "disch"),
  mp_per_capita_flow("I", "R", "recovery", "rec"),
  mp_per_capita_flow("H", "D", "death_H", "d_H"),
  mp_per_capita_flow("I", "D", "death_I", "d_I")
)

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
         S = extract_dot(state, "S"),
         E = extract_dot(state, "E"),
         I = extract_dot(state, "I"),
         H = extract_dot(state, "H"),
         R = extract_dot(state, "R"),
         D = extract_dot(state, "D"),
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

model <- mp_tmb_model_spec(
  before = computations,
  during = flows,
  default = default,
  must_save = c("state", "total_inflow", "infect")
)

model_simulator <-
  mp_simulator(
    model = model,
    time_steps = values$time.steps,
    outputs = c(age_over)
  )

current_output <- model_simulator$simulate()
expected_output <- default_model_simulator$report()

compare <- left_join(expected_result |> filter(matrix == "state"), current_output |> select(-matrix), by = c("time", "row", "col"))
