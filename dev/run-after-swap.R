## Run this 3rd, after "swap-renv.R"

library(dplyr)
library(macpan2) # have to reload macpan2 since i think i setup renv weird
devtools::load_all()

values <- readRDS("inst/models/five-year-age-groups/default_values.rds")
age.group.lower = seq(0, 80, by = 5)

# contact parameters
contact.pars.initial = mk_contact_pars(
  age.group.lower = age.group.lower,
  setting.weight = values$setting.weight
)

transmission = (values$transmissibility)*(contact.pars.initial$c.hat)

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
  N ~ S + E + I + H + R + D # Vector addition (no sum)
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
expected_output <- readRDS("dev/expected_output.RDS")

compare <- left_join(expected_output |> filter(matrix == "state"), current_output |> select(-matrix), by = c("time", "row", "col"))

summary(compare$value.x/compare$value.y) # value.x = expected, value.y = updated macpan
## Should all be equal, save for t = 0 and t = 61 NA's with upd macpan
