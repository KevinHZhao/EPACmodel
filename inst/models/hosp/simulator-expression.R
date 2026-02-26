states <- c(
  "S",
  "E",
  "I_R",
  "I_A",
  "I_D",
  "A_R",
  "A_CR",
  "A_CD",
  "A_D",
  "C_R",
  "C_D",
  "R",
  "D"
)

age_over <- c(
  states,
  "N",
  "prog_R",
  "prog_A",
  "prog_D",
  "rec_R",
  "adm_AR",
  "adm_ACR",
  "adm_ACD",
  "adm_AD",
  "adm_CR",
  "adm_CD",
  "disch_A",
  "disch_C",
  "d_A",
  "d_I",
  "d_C",
  "infect"
) # Epi variables to stratify by age over

nage <- length(age.group.lower)
agelabs <- paste0("lb", age.group.lower)

extract_dot <- function(v, var){
  return(v[grepl(paste0("^",var,"\\."), names(v))])
}

N <- rep(0, nage)
for (i in states){
  N <- N + extract_dot(values$state, i)
}

default <-
   list(
     transmission = transmission,
     progression_to_I_R = extract_dot(flow, "progression_to_I_R"),
     progression_to_I_A = extract_dot(flow, "progression_to_I_A"),
     progression_to_I_D = extract_dot(flow, "progression_to_I_D"),
     admission_to_A_R = extract_dot(flow, "admission_to_A_R"),
     admission_to_A_CR = extract_dot(flow, "admission_to_A_CR"),
     admission_to_A_CD = extract_dot(flow, "admission_to_A_CD"),
     admission_to_A_D = extract_dot(flow, "admission_to_A_D"),
     admission_to_C_R = extract_dot(flow, "admission_to_C_R"),
     admission_to_C_D = extract_dot(flow, "admission_to_C_D"),
     discharge_from_C_R = extract_dot(flow, "discharge_from_C_R"),
     discharge_from_A_R = extract_dot(flow, "discharge_from_A_R"),
     recovery_from_I_R = extract_dot(flow, "recovery_from_I_R"),
     death_from_I_D = extract_dot(flow, "death_from_I_D"),
     death_from_C_D = extract_dot(flow, "death_from_C_D"),
     death_from_A_D = extract_dot(flow, "death_from_A_D"),
     contact. = contact
   )

inits <-
  with(values,
       list(
         S = extract_dot(state, "S"),
         E = extract_dot(state, "E"),
         I_R = extract_dot(state, "I_R"),
         I_A = extract_dot(state, "I_A"),
         I_D = extract_dot(state, "I_D"),
         A_R = extract_dot(state, "A_R"),
         A_CR = extract_dot(state, "A_CR"),
         A_CD = extract_dot(state, "A_CD"),
         A_D = extract_dot(state, "A_D"),
         C_R = extract_dot(state, "C_R"),
         C_D = extract_dot(state, "C_D"),
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
    outputs = c(states, age_over) # This can be changed to for example, age_over to get more of the values for debugging
  )
