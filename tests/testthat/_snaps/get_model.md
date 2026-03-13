# get_model() returns an expected snapshot for five-year-age-groups

    Code
      model
    Output
      ---------------------
      Default values:
              quantity value
          transmission   0.5
           progression   0.5
       hospitalization   0.5
             discharge   0.5
              recovery   0.5
               death_H   0.5
               death_I   0.5
              contact.   0.0
                     S   0.0
                     E   0.0
                     I   0.0
                     H   0.0
                     R   0.0
                     D   0.0
      ---------------------
      
      ---------------------
      Before the simulation loop (t = 0):
      ---------------------
      1: N ~ S + E + I + H + R + D
      
      ---------------------
      At every iteration of the simulation loop (t = 1 to T):
      ---------------------
      1: scaled_infected ~ I * transmission/N
      2: macpan2::mp_per_capita_flow(from = "S", to = "E", rate = "contact. %*% scaled_infected", 
           flow_name = "infect")
      3: macpan2::mp_per_capita_flow(from = "E", to = "I", rate = "progression", 
           flow_name = "prog")
      4: macpan2::mp_per_capita_flow(from = "I", to = "H", rate = "hospitalization", 
           flow_name = "hosp")
      5: macpan2::mp_per_capita_flow(from = "H", to = "R", rate = "discharge", 
           flow_name = "disch")
      6: macpan2::mp_per_capita_flow(from = "I", to = "R", rate = "recovery", 
           flow_name = "rec")
      7: macpan2::mp_per_capita_flow(from = "H", to = "D", rate = "death_H", 
           flow_name = "d_H")
      8: macpan2::mp_per_capita_flow(from = "I", to = "D", rate = "death_I", 
           flow_name = "d_I")
      

# get_model() returns an expected snapshot for hosp

    Code
      model
    Output
      ---------------------
      Default values:
                 quantity value
             transmission   0.5
       progression_to_I_R   0.5
       progression_to_I_A   0.5
       progression_to_I_D   0.5
         admission_to_A_R   0.5
        admission_to_A_CR   0.5
        admission_to_A_CD   0.5
         admission_to_A_D   0.5
         admission_to_C_R   0.5
         admission_to_C_D   0.5
       discharge_from_A_R   0.5
       discharge_from_C_R   0.5
        recovery_from_I_R   0.5
           death_from_I_D   0.5
           death_from_A_D   0.5
           death_from_C_D   0.5
                 contact.   0.0
                        S   0.0
                        E   0.0
                      I_R   0.0
                      I_A   0.0
                      I_D   0.0
                      A_R   0.0
                     A_CR   0.0
                     A_CD   0.0
                      A_D   0.0
                      C_D   0.0
                      C_R   0.0
                        R   0.0
                        D   0.0
      ---------------------
      
      ---------------------
      Before the simulation loop (t = 0):
      ---------------------
      1: N ~ S + E + I_R + I_A + I_D + A_R + A_CR + A_CD + A_D + C_R + C_D + R + D
      
      ---------------------
      At every iteration of the simulation loop (t = 1 to T):
      ---------------------
       1: I ~ I_R + I_A + I_D
       2: scaled_infected ~ I * transmission/N
       3: macpan2::mp_per_capita_flow(from = "S", to = "E", rate = "contact. %*% scaled_infected", 
            flow_name = "infect")
       4: macpan2::mp_per_capita_flow(from = "E", to = "I_R", rate = "progression_to_I_R", 
            flow_name = "prog_R")
       5: macpan2::mp_per_capita_flow(from = "E", to = "I_A", rate = "progression_to_I_A", 
            flow_name = "prog_A")
       6: macpan2::mp_per_capita_flow(from = "E", to = "I_D", rate = "progression_to_I_D", 
            flow_name = "prog_D")
       7: macpan2::mp_per_capita_flow(from = "I_R", to = "R", rate = "recovery_from_I_R", 
            flow_name = "rec_R")
       8: macpan2::mp_per_capita_flow(from = "I_D", to = "D", rate = "death_from_I_D", 
            flow_name = "d_I")
       9: macpan2::mp_per_capita_flow(from = "I_A", to = "A_R", rate = "admission_to_A_R", 
            flow_name = "adm_AR")
      10: macpan2::mp_per_capita_flow(from = "I_A", to = "A_CR", rate = "admission_to_A_CR", 
            flow_name = "adm_ACR")
      11: macpan2::mp_per_capita_flow(from = "I_A", to = "A_CD", rate = "admission_to_A_CD", 
            flow_name = "adm_ACD")
      12: macpan2::mp_per_capita_flow(from = "I_A", to = "A_D", rate = "admission_to_A_D", 
            flow_name = "adm_AD")
      13: macpan2::mp_per_capita_flow(from = "A_R", to = "R", rate = "discharge_from_A_R", 
            flow_name = "disch_A")
      14: macpan2::mp_per_capita_flow(from = "A_CR", to = "C_R", rate = "admission_to_C_R", 
            flow_name = "adm_CR")
      15: macpan2::mp_per_capita_flow(from = "A_CD", to = "C_D", rate = "admission_to_C_D", 
            flow_name = "adm_CD")
      16: macpan2::mp_per_capita_flow(from = "A_D", to = "D", rate = "death_from_A_D", 
            flow_name = "d_A")
      17: macpan2::mp_per_capita_flow(from = "C_R", to = "R", rate = "discharge_from_C_R", 
            flow_name = "disch_C")
      18: macpan2::mp_per_capita_flow(from = "C_D", to = "D", rate = "death_from_C_D", 
            flow_name = "d_C")
      

# get_model() returns an expected snapshot for old-and-young

    Code
      model
    Output
      ---------------------
      Default values:
              quantity value
          transmission   0.5
           progression   0.5
       hospitalization   0.5
             discharge   0.5
              recovery   0.5
               death_H   0.5
               death_I   0.5
              contact.   0.0
                     S   0.0
                     E   0.0
                     I   0.0
                     H   0.0
                     R   0.0
                     D   0.0
      ---------------------
      
      ---------------------
      Before the simulation loop (t = 0):
      ---------------------
      1: N ~ S + E + I + H + R + D
      
      ---------------------
      At every iteration of the simulation loop (t = 1 to T):
      ---------------------
      1: scaled_infected ~ I * transmission/N
      2: macpan2::mp_per_capita_flow(from = "S", to = "E", rate = "contact. %*% scaled_infected", 
           flow_name = "infect")
      3: macpan2::mp_per_capita_flow(from = "E", to = "I", rate = "progression", 
           flow_name = "prog")
      4: macpan2::mp_per_capita_flow(from = "I", to = "H", rate = "hospitalization", 
           flow_name = "hosp")
      5: macpan2::mp_per_capita_flow(from = "H", to = "R", rate = "discharge", 
           flow_name = "disch")
      6: macpan2::mp_per_capita_flow(from = "I", to = "R", rate = "recovery", 
           flow_name = "rec")
      7: macpan2::mp_per_capita_flow(from = "H", to = "D", rate = "death_H", 
           flow_name = "d_H")
      8: macpan2::mp_per_capita_flow(from = "I", to = "D", rate = "death_I", 
           flow_name = "d_I")
      

