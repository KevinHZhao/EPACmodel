computations <- list(
  N ~ S + E + I + H + R + D # Vector addition (no sum)
)

flows <- list(
  scaled_infected ~ I * transmission / N,
  macpan2::mp_per_capita_flow("S", "E", "contact. %*% scaled_infected", "infect"),
  macpan2::mp_per_capita_flow("E", "I", "progression", "prog"),
  macpan2::mp_per_capita_flow("I", "H", "hospitalization", "hosp"),
  macpan2::mp_per_capita_flow("H", "R", "discharge", "disch"),
  macpan2::mp_per_capita_flow("I", "R", "recovery", "rec"),
  macpan2::mp_per_capita_flow("H", "D", "death_H", "d_H"),
  macpan2::mp_per_capita_flow("I", "D", "death_I", "d_I")
)

default <-
   list(
     transmission = 0.5,
     progression = 0.5,
     hospitalization = 0.5,
     discharge = 0.5,
     recovery = 0.5,
     death_H = 0.5,
     death_I = 0.5,
     contact. = 0
  )

inits <-
  list(
    S = 0,
    E = 0,
    I = 0,
    H = 0,
    R = 0,
    D = 0
  )

model <- macpan2::mp_tmb_model_spec(
  before = computations,
  during = flows,
  default = default,
  inits = inits,
  must_save = c("state")
)
