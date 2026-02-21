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
      

