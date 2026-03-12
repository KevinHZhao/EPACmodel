# run-before-simulator.R
age.group.lower = seq(0, 80, by = 5)

# make contact data, if not provided
if(is.null(values$contact.pars)){
  values$contact.pars = mk_contact_pars(
    age.group.lower = age.group.lower,
    setting.weight = values$setting.weight,
    pop.new = values$pop
  )
}

flow <- calculate_flow(model.name, values)
transmission <- calculate_transmission(model.name, values)

contact <- values$contact.pars$p.mat

# make contact data for scenario, if not provided
if(scenario.name == "change-contacts" & is.null(values$contact.pars.new)){
  values$contact.pars.new = mk_contact_pars(
    age.group.lower = seq(0, 80, by = 5),
    setting.weight = values$setting.weight.new,
    pop.new = values$pop
  )
}

# simulator-expression.R

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
agelabs <- age.group.lower # change to remove lb

extract_dot <- function(v, var){
  return(unname(v[grepl(paste0("^",var,"\\."), names(v))]))
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
    outputs = c(states, output_flows) # This can be changed to for example, age_over to get more of the values for debugging
  )

# run-after-simulator.R

# set up model simulator to accept updated parameter values
pf <- (data.frame()
       |> add_to_pf("state", values$state)
       |> add_to_pf("flow", flow)
       |> add_to_pf("transmission", transmission)
       |> add_to_pf("contact.", contact)
)

if (scenario.name == "change-contacts") {
  contact_changepoints_to_fill <- calculate_contact_changepoints(values)
  contact_values_to_fill <- calculate_contact_values(values)
  transmission_values_to_fill <- calculate_transmission_values(values)

  model_simulator$add$matrices(
    contact_changepoints = contact_changepoints_to_fill
    # need to have "changepoint" for initial set of pars at t = 0
    , contact_pointer = 0,
    contact_values = contact_values_to_fill,
    transmission_values = transmission_values_to_fill,
    n.age.group = length(seq(0, 80, by = 5)),
    .mats_to_save = c("contact.", "transmission"),
    .mats_to_return = c("contact.", "transmission")
  )$insert$expressions(
    contact_pointer ~ time_group(contact_pointer, contact_changepoints),
    contact. ~ block(
      contact_values, n.age.group * contact_pointer,
      0, n.age.group, n.age.group
    ),
    transmission ~ block(
      transmission_values,
      0, contact_pointer,
      n.age.group, 1
    ),
    .phase = "during"
  )

  # set up to accept updated scenario parameters
  pf <- (pf
         |> add_to_pf("contact_changepoints", contact_changepoints_to_fill)
         |> add_to_pf("contact_values", contact_values_to_fill)
         |> add_to_pf("transmission_values", transmission_values_to_fill)
  )
}

# model_simulator$replace$params_frame(pf) make this work later

model_simulator
