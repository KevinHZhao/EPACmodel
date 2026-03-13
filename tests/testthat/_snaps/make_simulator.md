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
      

# simulator from hosp snapshot is consistent

    Code
      make_simulator("hosp")
    Output
      ---------------------
      Before the simulation loop (t = 0):
      ---------------------
      1: N ~ S + E + I_R + I_A + I_D + A_R + A_CR + A_CD + A_D + C_R + C_D + R + D
      
      ---------------------
      At every iteration of the simulation loop (t = 1 to 60):
      ---------------------
       1: I ~ I_R + I_A + I_D
       2: scaled_infected ~ I * transmission/N
       3: infect ~ S * (contact. %*% scaled_infected)
       4: prog_R ~ E * (progression_to_I_R)
       5: prog_A ~ E * (progression_to_I_A)
       6: prog_D ~ E * (progression_to_I_D)
       7: rec_R ~ I_R * (recovery_from_I_R)
       8: d_I ~ I_D * (death_from_I_D)
       9: adm_AR ~ I_A * (admission_to_A_R)
      10: adm_ACR ~ I_A * (admission_to_A_CR)
      11: adm_ACD ~ I_A * (admission_to_A_CD)
      12: adm_AD ~ I_A * (admission_to_A_D)
      13: disch_A ~ A_R * (discharge_from_A_R)
      14: adm_CR ~ A_CR * (admission_to_C_R)
      15: adm_CD ~ A_CD * (admission_to_C_D)
      16: d_A ~ A_D * (death_from_A_D)
      17: disch_C ~ C_R * (discharge_from_C_R)
      18: d_C ~ C_D * (death_from_C_D)
      19: S ~ S - infect
      20: E ~ E + infect - prog_R - prog_A - prog_D
      21: I_R ~ I_R + prog_R - rec_R
      22: I_A ~ I_A + prog_A - adm_AR - adm_ACR - adm_ACD - adm_AD
      23: I_D ~ I_D + prog_D - d_I
      24: R ~ R + rec_R + disch_A + disch_C
      25: D ~ D + d_I + d_A + d_C
      26: A_R ~ A_R + adm_AR - disch_A
      27: A_CR ~ A_CR + adm_ACR - adm_CR
      28: A_CD ~ A_CD + adm_ACD - adm_CD
      29: A_D ~ A_D + adm_AD - d_A
      30: C_R ~ C_R + adm_CR - disch_C
      31: C_D ~ C_D + adm_CD - d_C
      

# simulator from hosp with change-contacts snapshot is consistent

    Code
      make_simulator("hosp", "change-contacts")
    Output
      ---------------------
      Before the simulation loop (t = 0):
      ---------------------
      1: N ~ S + E + I_R + I_A + I_D + A_R + A_CR + A_CD + A_D + C_R + C_D + R + D
      
      ---------------------
      At every iteration of the simulation loop (t = 1 to 60):
      ---------------------
       1: contact_pointer ~ time_group(contact_pointer, contact_changepoints)
       2: contact. ~ block(contact_values, n.age.group * contact_pointer, 0, n.age.group, n.age.group)
       3: transmission ~ block(transmission_values, 0, contact_pointer, n.age.group, 1)
       4: I ~ I_R + I_A + I_D
       5: scaled_infected ~ I * transmission/N
       6: infect ~ S * (contact. %*% scaled_infected)
       7: prog_R ~ E * (progression_to_I_R)
       8: prog_A ~ E * (progression_to_I_A)
       9: prog_D ~ E * (progression_to_I_D)
      10: rec_R ~ I_R * (recovery_from_I_R)
      11: d_I ~ I_D * (death_from_I_D)
      12: adm_AR ~ I_A * (admission_to_A_R)
      13: adm_ACR ~ I_A * (admission_to_A_CR)
      14: adm_ACD ~ I_A * (admission_to_A_CD)
      15: adm_AD ~ I_A * (admission_to_A_D)
      16: disch_A ~ A_R * (discharge_from_A_R)
      17: adm_CR ~ A_CR * (admission_to_C_R)
      18: adm_CD ~ A_CD * (admission_to_C_D)
      19: d_A ~ A_D * (death_from_A_D)
      20: disch_C ~ C_R * (discharge_from_C_R)
      21: d_C ~ C_D * (death_from_C_D)
      22: S ~ S - infect
      23: E ~ E + infect - prog_R - prog_A - prog_D
      24: I_R ~ I_R + prog_R - rec_R
      25: I_A ~ I_A + prog_A - adm_AR - adm_ACR - adm_ACD - adm_AD
      26: I_D ~ I_D + prog_D - d_I
      27: R ~ R + rec_R + disch_A + disch_C
      28: D ~ D + d_I + d_A + d_C
      29: A_R ~ A_R + adm_AR - disch_A
      30: A_CR ~ A_CR + adm_ACR - adm_CR
      31: A_CD ~ A_CD + adm_ACD - adm_CD
      32: A_D ~ A_D + adm_AD - d_A
      33: C_R ~ C_R + adm_CR - disch_C
      34: C_D ~ C_D + adm_CD - d_C
      

# simulator from old-and-young snapshot is consistent

    Code
      make_simulator("old-and-young")
    Output
      ---------------------
      Before the simulation loop (t = 0):
      ---------------------
      1: N ~ S + E + I + H + R + D
      
      ---------------------
      At every iteration of the simulation loop (t = 1 to 150):
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
      

# simulator from old-and-young with change-transmission snapshot is consistent

    Code
      make_simulator("old-and-young", "change-transmission")
    Output
      ---------------------
      Before the simulation loop (t = 0):
      ---------------------
      1: N ~ S + E + I + H + R + D
      
      ---------------------
      At every iteration of the simulation loop (t = 1 to 150):
      ---------------------
       1: transmission ~ c(time_var(transmission_y_values, transmission_y_changepoints), time_var(transmission_o_values, transmission_o_changepoints))
       2: scaled_infected ~ I * transmission/N
       3: infect ~ S * (contact. %*% scaled_infected)
       4: prog ~ E * (progression)
       5: hosp ~ I * (hospitalization)
       6: disch ~ H * (discharge)
       7: rec ~ I * (recovery)
       8: d_H ~ H * (death_H)
       9: d_I ~ I * (death_I)
      10: S ~ S - infect
      11: E ~ E + infect - prog
      12: I ~ I + prog - hosp - rec - d_I
      13: H ~ H + hosp - disch - d_H
      14: R ~ R + disch + rec
      15: D ~ D + d_H + d_I
      

