# simulator from five-year-age-groups snapshot is consistent

    Code
      make_simulator("five-year-age-groups")
    Output
      ---------------------
      Before the simulation loop (t = 0):
      ---------------------
      1: N ~ S + E + I + H + R + D
      
      ---------------------
      At every iteration of the simulation loop (t = 1 to 60):
      ---------------------
       1: scaled_infected ~ I * transmission/N
       2: infect ~ S * (contact. %*% scaled_infected)
       3: prog ~ E * (progression)
       4: hosp ~ I * (hospitalization)
       5: disch ~ H * (discharge)
       6: rec ~ I * (recovery)
       7: d_H ~ H * (death_H)
       8: d_I ~ I * (death_I)
       9: S ~ S - infect
      10: E ~ E + infect - prog
      11: I ~ I + prog - hosp - rec - d_I
      12: H ~ H + hosp - disch - d_H
      13: R ~ R + disch + rec
      14: D ~ D + d_H + d_I
      

# simulator from five-year-age-groups with change-contacts snapshot is consistent

    Code
      make_simulator("five-year-age-groups", "change-contacts")
    Output
      ---------------------
      Before the simulation loop (t = 0):
      ---------------------
      1: N ~ S + E + I + H + R + D
      
      ---------------------
      At every iteration of the simulation loop (t = 1 to 60):
      ---------------------
       1: contact_pointer ~ time_group(contact_pointer, contact_changepoints)
       2: contact. ~ block(contact_values, n.age.group * contact_pointer, 0, n.age.group, n.age.group)
       3: transmission ~ block(transmission_values, 0, contact_pointer, n.age.group, 1)
       4: scaled_infected ~ I * transmission/N
       5: infect ~ S * (contact. %*% scaled_infected)
       6: prog ~ E * (progression)
       7: hosp ~ I * (hospitalization)
       8: disch ~ H * (discharge)
       9: rec ~ I * (recovery)
      10: d_H ~ H * (death_H)
      11: d_I ~ I * (death_I)
      12: S ~ S - infect
      13: E ~ E + infect - prog
      14: I ~ I + prog - hosp - rec - d_I
      15: H ~ H + hosp - disch - d_H
      16: R ~ R + disch + rec
      17: D ~ D + d_H + d_I
      

