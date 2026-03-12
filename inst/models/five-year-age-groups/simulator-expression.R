# run-before-simulator.R
# lower bounds for age groups
age.group.lower = seq(0, 80, by = 5)

# contact parameters
contact.pars.initial = mk_contact_pars(
  age.group.lower = age.group.lower,
  setting.weight = values$setting.weight
)

transmission = (values$transmissibility)*(contact.pars.initial$c.hat)

if(scenario.name == "change-contacts"){
  contact.pars.new = mk_contact_pars(
    age.group.lower = age.group.lower,
    setting.weight = values$setting.weight.new
  )
}

# decode parameters into model flows
flow <- init_flow_vec(
  epi_names = c("progression", "recovery", "hospitalization", "discharge", "death_H", "death_I"),
  age_groups = age.group.lower
)

values$flow <- (flow
                # outflow for E
                |> update_flow(
                  pattern = "^progression",
                  value = 1/values$days_incubation
                )
                # outflows for I
                |> update_flow(
                  pattern = "^recovery",
                  value = (1-values$prop_hosp-1/(1/values$prop_IFR_all - 1/values$prop_IFR_hosp))*1/values$days_infectious
                )
                |> update_flow(
                  pattern = "^hospitalization",
                  value = values$prop_hosp*1/values$days_infectious
                )
                |> update_flow(
                  pattern = "^death_I",
                  value = 1/(1/values$prop_IFR_all - 1/values$prop_IFR_hosp)*1/values$days_infectious
                )
                # outflows for H
                |> update_flow(
                  pattern = "^discharge",
                  value = (1-values$prop_IFR_hosp)*1/values$days_hosp
                )
                |> update_flow(
                  pattern = "^death_H",
                  value = values$prop_IFR_hosp*1/values$days_hosp
                )
)

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

nage <- length(age.group.lower)
agelabs <- age.group.lower # changed to remove lb

extract_dot <- function(v, var){
  return(unname(v[grepl(paste0("^",var,"\\."), names(v))]))
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
    outputs = c(states, output_flows) # This can be changed to for example, age_over to get more of the values for debugging
  )

# run-after-simulator.R
if(scenario.name == "change-contacts"){
  model_simulator$add$matrices(
    contact_changepoints = c(0, values$intervention.day)
    # need to have "changepoint" for initial set of pars at t = 0
    , contact_pointer = 0
    , contact_values = rbind(contact.pars.initial$p.mat,
                             contact.pars.new$p.mat)
    , transmission_values = cbind(
      values$transmissibility*contact.pars.initial$c.hat,
      values$trans.factor*values$transmissibility*contact.pars.new$c.hat
    )
    , n.age.group = length(age.group.lower)
    , .mats_to_save = c("contact.", "transmission")
    #, .mats_to_return = c("contact.", "transmission") # Not returning for consistency with other scenario
  )$insert$expressions(
    contact_pointer ~ time_group(contact_pointer, contact_changepoints)
    , contact. ~ block(contact_values, n.age.group * contact_pointer,
                       0, n.age.group, n.age.group)
    , transmission ~ block(transmission_values,
                           0, contact_pointer,
                           n.age.group, 1)
    , .phase = "during"
  ) # This should still work, but might not be a good way to do things
}

model_simulator
