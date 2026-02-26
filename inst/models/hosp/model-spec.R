computations <- list(
  N ~ S + E + I_R + I_A + I_D + A_R + A_CR + A_CD + A_D + C_R + C_D + R + D # Vector addition (no sum)
)

flows <- list(
  I ~ I_R + I_A + I_D,
  scaled_infected ~ I * transmission / N,
  macpan2::mp_per_capita_flow("S", "E", "contact. %*% scaled_infected", "infect"),
  macpan2::mp_per_capita_flow("E", "I_R", "progression_to_I_R", "prog_R"),
  macpan2::mp_per_capita_flow("E", "I_A", "progression_to_I_A", "prog_A"),
  macpan2::mp_per_capita_flow("E", "I_D", "progression_to_I_D", "prog_D"),
  macpan2::mp_per_capita_flow("I_R", "R", "recovery_from_I_R", "rec_R"),
  macpan2::mp_per_capita_flow("I_D", "D", "death_from_I_D", "d_I"),
  macpan2::mp_per_capita_flow("I_A", "A_R", "admission_to_A_R", "adm_AR"),
  macpan2::mp_per_capita_flow("I_A", "A_CR", "admission_to_A_CR", "adm_ACR"),
  macpan2::mp_per_capita_flow("I_A", "A_CD", "admission_to_A_CD", "adm_ACD"),
  macpan2::mp_per_capita_flow("I_A", "A_D", "admission_to_A_D", "adm_AD"),
  macpan2::mp_per_capita_flow("A_R", "R", "discharge_from_A_R", "disch_A"),
  macpan2::mp_per_capita_flow("A_CR", "C_R", "admission_to_C_R", "adm_CR"),
  macpan2::mp_per_capita_flow("A_CD", "C_D", "admission_to_C_D", "adm_CD"),
  macpan2::mp_per_capita_flow("A_D", "D", "death_from_A_D", "d_A"),
  macpan2::mp_per_capita_flow("C_R", "R", "discharge_from_C_R", "disch_C"),
  macpan2::mp_per_capita_flow("C_D", "D", "death_from_C_D", "d_C")
)

default <-
   list(
     transmission = 0.5,
     progression_to_I_R = 0.5,
     progression_to_I_A = 0.5,
     progression_to_I_D = 0.5,
     admission_to_A_R = 0.5,
     admission_to_A_CR = 0.5,
     admission_to_A_CD = 0.5,
     admission_to_A_D = 0.5,
     admission_to_C_R = 0.5,
     admission_to_C_D = 0.5,
     discharge_from_A_R = 0.5,
     discharge_from_C_R = 0.5,
     recovery_from_I_R = 0.5,
     death_from_I_D = 0.5,
     death_from_A_D = 0.5,
     death_from_C_D = 0.5,
     contact. = 0
  )

inits <-
  list(
    S = 0,
    E = 0,
    I_R = 0,
    I_A = 0,
    I_D = 0,
    A_R = 0,
    A_CR = 0,
    A_CD = 0,
    A_D = 0,
    C_D = 0,
    C_R = 0,
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
