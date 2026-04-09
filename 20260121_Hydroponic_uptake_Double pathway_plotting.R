# Project title: PFAS modeling plant uptake
# Project owner: Weixin Huang
# Creation date: 20241009
# Updated date: 20260121
# Update content: Plotting

# Summary of PFAS plant uptake studies by 2020: https://doi.org/10.1007/s40726-020-00168-y

# Manual for section 1: 
# [Hydroponic "training" context] 
# Plant is tomato, total growth period is 96 days with 30 days of fruiting, assuming fruiting starts from day 66, temperature is 25 degrees. 
# [Hydroponic "verification" context] 
# Plant is tomato, total growth period is 14 days with 30 days of fruiting, assuming fruiting starts from day 52, temperature is 25 degrees. 
# [Soil context]
# Plant is also tomato, 

# Scripts:
# 1. Package loading
library(readxl)

# 2. Load data/parameters
# 2.1. Load parameters
Parameter <- read_excel("C:/Users/huang067/OneDrive - Wageningen University & Research/Huang067/Chapter 3/PFAS modeling/PFASPara_Tomato_Dual_Chapter3_Cleaned.xlsx")
#Parameter <- read_excel("C:/Users/whuang29/OneDrive - Wageningen University & Research/Huang067/Chapter 3/PFAS modeling/PFASPara_Tomato_Dual_Chapter3_Cleaned.xlsx")
as.data.frame(Parameter)
Para <- Parameter[,4:11]                                                        # Verify the scope every time you change parameters!!

# 2.2 Parameters defining
# 2.2.1 Compound-related parameters
C_p <- Para[1,]                                                                 # PFAS concentration in solution (Unit is μg/L) 
lgKow_i <- Para[2,]                                                             # Octanol-water partition coefficient of anionic PFAS (dimensionless) (lgkow: https://doi.org/10.1002/etc.5716).

# 2.2.2 Context-related & time-bounded parameters
t <- Para[3,]                                                                   # Growth/exposure time (days)
t_fruiting <- Para[4,]                                                          # Days of fruiting (days)
V_p <- Para[5,]                                                                 # Volume of tank for hydroponic growth

# 2.2.3 Plant-related parameters
# Initial biomass of plant tissues on day 1, roots, stems & leaves have a initial biomass of 0.001 (kg).
M0_root <- Para[6,]                                                     
M0_stem <- Para[7,]                                                      
M0_twig <- Para[8,]                                                    
M0_leaf <- Para[9,]                                                         
                                                  
# Water content of plant tissues (kg/kg)
VWater_root <- Para[10,]                                                    
VWater_stem <- Para[11,]                                                    
VWater_twig <- Para[12,]                                                   
VWater_leaf <- Para[13,]                                                     
VWater_fruit <- Para[14,]         

# Calculated growth rates of plant tissues (kg/day)
k_root <- Para[15,]                                                     
k_stem <- Para[16,]                                                    
k_twig <- Para[17,]                                                   
k_leaf <- Para[18,]                                                     
k_fruit <- Para[19,]    

# Proportion (mass) of apoplastic and symplastic space in roots
P_apo <- Para[20,]                                                              # Weight proportion of apoplastic space of total roots

# Proportion of areas between the interface of apoplastic space and solution
PA_apo <- Para[21,] 

# Stem and twig length calculation based on density and cross-sectional areas
ρ_stem <- Para[22,]
ρ_twig <- Para[23,]
A_stem <- Para[24,]
A_twig <- Para[25,]

# 2.2.4 Transpiration-related parameters
kQ_leaf <- Para[26,]                                                            # Coefficient of transpiration per biomass growth of leaves (L/kg)
RQ_fruit <- Para[27,]                                                           # Ratio of xylem-fruit transpiration to that of xylem-leaf
PQ_apo <- Para[28,]                                                             # Proportion of contribution to the water flux by the Apoplasstic pathway
ρ_s <- Para[29,]                                                                # Density of the nutrient solution

# 2.2.5 Adsorption, binding, and other parameters
# Unit conversion factors
APro_sym <- Para[30,]
AS_sym <- Para[31,]
Aad_stem <- Para[32,]
Aad_twigXY <- Para[33,]
APro_ph <- Para[34,]
Aad_twigPH <- Para[35,]
AS_ph <- Para[36,]

# Coefficients
uPro_apo2sym <- Para[37,]
uPro_s2sym <- Para[38,]
u_sym <- Para[39,]
u_apo <- Para[40,]
uad_stem <- Para[41,]
uad_twigXY <- Para[42,]
uPro_ph <- Para[43,]
uad_twigPH <- Para[44,]
u_ph <- Para[45,]

# Tipping point across PFAS substances
lgKow_i_apo2sym <- Para[46,]
lgKow_i_sym <- Para[47,]
lgKow_i_stem <- Para[48,]
lgKow_i_twigXY <- Para[49,]
lgKow_i_ph <- Para[50,]
lgKow_i_twigPH<- Para[51,]

# Gaussian factors for Gaussian-type movement
B <- Para[52,]

# 【Only for soil case】2.2.6 Soil-related correction parameters
#R_kroot <- Para[60,]                                                            # Corrective factor for root growth in soil. We expected a relatively smaller growth due to the existence of soil and other particles.
#R_kplant <- Para[61,]                                                           # Corrective factor for plant growth in soil, relatively small. ref: 10.11159/icmie18.131; Hydroponic Tomato grows higher but soil grown tomato develops much more branches, and tomato yield is comparable: https://doi.org/10.1080/01904167.2025.2506687
#R_Papo <- Para[62,]                                                             # soil grown plants will develop apoplastic barriers which restricts Apoplastic flow, leading more dominant symplastic flow. Hence correction. Ref: https://doi.org/10.1016/j.envpol.2020.114736; https://doi.org/10.1111/pce.15067

# 【Only for soil case】2.2.7 Soil-specific parameters
#C_soil_1 <- Para[63,]
#C_soil_2 <- Para[64,]
#C_soil_3 <- Para[65,]
#C_soil_4 <- Para[66,]
#C_soil_5 <- Para[67,]
#OC <- Para[68,]                                                                # To be adjusted per case
#Vwater_soil <- Para[69,]
#ρ_soilWet <- Para[70,]
#lgKoc <- Para[71,]

# 2.3 Create dummy variables
M_root <- k_root #for 4.1 equations
v_apo <- k_root 
m_apo <- k_root 
C_apo <- k_root
Smax_sym <- k_root # for 4.2.3 equations
S_apo2sym <- k_root # for 4.2.3 equations
S_s2sym <- k_root # for 4.2.3 equations
J_apo2sym <- k_root # for 4.2.3 equations
J_s2sym <- k_root # for 4.2.3 equations
C_sym <- k_root # for 4.2.3 equations
M_leaf <- k_leaf #for 4.3.1 equations
Q_leaf <- k_leaf #for 4.3.1 equations
m_leaf <- k_leaf
C_leaf <- k_leaf
Q_fruit <- k_fruit #for 4.3.1 equations
M_fruit <- k_fruit #for 4.3.1 equations
m_fruit <- k_fruit #for 4.3.1 equations
C_fruit <- k_fruit #for 4.3.1 equations
m_stem <- k_stem #for 4.3.1 equations
m_twig <- k_twig #for 4.3.1 equations
M_stem <- k_stem #for 4.3.2 equations
M_twig <- k_twig #for 4.3.3 equations
V_twig <- k_twig #for 4.3.3 equations
Qday_leaf <- k_leaf # for 3.4 equations
Qday_fruit <- k_fruit # for 3.4 equations
V_p_correct <- k_root # for 4.2 equations
J_sym <- k_root # for 4.2 equations
m_sym <- k_root # for 4.2 equations
C_s <- k_root 
m_s <- k_root 
dC_ph <- k_fruit
Smax_ph <- k_fruit
J_fruit <- k_fruit
S_ph <- k_fruit
v_twigPH <- k_twig

# 3. Plant biomass gain & Transpiration
# 3.1 Time (# harvest = growth + fruiting)
t_growth <- t - t_fruiting                                                      # Separate the growth period and fruiting period

harvest <- unique(as.vector(as.matrix(t)))
growth <- unique(as.vector(as.matrix(t_growth)))
fruiting <- unique(as.vector(as.matrix(t_fruiting)))

# 3.2 Biomass calculation 
# 3.2.1 Roots (kg of root symplastic space & apoplastic space)
for (i in 1:harvest){                                                           
  M_root[i,] <- k_root*i + M0_root
}
P_apo <- P_apo[rep(1,harvest),]                                             
M_apo <- M_root*P_apo
M_sym <- M_root - M_apo

# 3.2.2 Aboveground parts (kg of oot symplastic, stem, twig, leaf, fruit). (Outdated: Linear growth: https://doi.org/10.1016/j.scienta.2006.07.032, see parameter excelsheet)
# For all tissues and no consideration of fruiting yet
for (i in 1:harvest){
  M_leaf[i,] <- k_leaf*i + M0_leaf
  M_stem[i,] <- k_stem*i + M0_stem
  M_twig[i,] <- k_twig*i + M0_twig
  M_fruit[i,] <- i*0                                                            # When no fruits, biomass is 0
}

# Fruiting 
for (i in 1:fruiting){
  M_fruit[growth + i,] <- k_fruit*i + M_fruit[growth,]                          # With fruits, biomass is gainning fast
}

# Before fruiting, M_above <- M_stem + M_twig + M_leaf
# After fruiting, M_above <- M_stem + M_twig + M_leaf + M_fruit

# 3.3 Adsorption area for stems and twigs
# Assuming specific volume of xylem is constant in stems and twigs during the growth period (no phloem transportation), then we get:
# Similar to what happen on roots, vascular bundles may also adsorb PFAS when those moves in the "pipes". Hence:
ρ_stem <- ρ_stem[rep(1,harvest),]
A_stem <- A_stem[rep(1,harvest),] 
V_stem <- M_stem/ρ_stem
L_stem <- V_stem/A_stem

ρ_twig <- ρ_twig[rep(1,harvest),]
A_twig <- A_twig[rep(1,harvest),]
V_twig <- M_twig/ρ_twig
L_twig <- V_twig/A_twig

# 3.4 Transpiration (if still needed)
# Dynamic transpiration of leaves associated with plant growth (assuming linear relationship, ref: https://doi.org/10.1016/j.scitotenv.2020.137333. Transpiration volume was very well correlated with the plantmass (Pearson's r=0.939, p=0.000018), as the plant growth directly (and linearly) depends on the plant transpiration (Arkley, 1963).)
# Day 1 transpiration leaf
Q_leaf[1,] <- kQ_leaf*M_leaf[1,]  

# After day 1 transpiration leaf
for (i in 2:harvest){
  Q_leaf[i,] <- kQ_leaf*M_leaf[i,] + Q_leaf[i-1,]                               # kQ_leaf = 2.45
}
for (i in 1:harvest){
  Q_fruit[i,] <- i*0                                                          #When no fruits, transpiration is 0
  m_fruit[i,] <- i*0                                                          #When no fruits, PFAS mass is 0
  C_fruit[i,] <- i*0                                                          #When no fruits, PFAS concentration is 0
  m_stem[i,] <- i*0
  m_twig[i,] <- i*0
}

# Dynamic transpiration of fruit associated with plant growth (assuming linear relationship)
kQ_fruit <- kQ_leaf*RQ_fruit

# Calculate the amount of transpiration due to fruits during the fruiting period.
for (i in 1:fruiting){
  Q_fruit[growth + i,] <- kQ_fruit*M_fruit[growth+i,] + Q_fruit[growth+i-1,]
}

for (i in 1:harvest){
  Qday_leaf[i,] <- kQ_leaf*M_leaf[i,]                                           
  Qday_fruit[i,] <- kQ_fruit*M_fruit[i,]                                        
}
Qday_total <- Qday_leaf + Qday_fruit

# Transpired ratio between root symplastic and aboveground parts
VWater_root <- VWater_root[rep(1,harvest),]
VWater_leaf <- VWater_leaf[rep(1,harvest),]
VWater_fruit <- VWater_fruit[rep(1,harvest),]
VWater_twig <- VWater_twig[rep(1,harvest),]
VWater_stem <- VWater_stem[rep(1,harvest),]
V_above <- M_leaf*VWater_leaf + M_fruit*VWater_fruit + M_twig*VWater_twig + M_stem*VWater_stem

# Water flow contribution ratio
PQ_apo <- PQ_apo[rep(1,harvest),]

V_sym <- M_root*VWater_root*(1 - PQ_apo)                                        # Contribution of water volume in root symplastic space is often found around 50%.

# 4. PFAS uptake by Roots 
# 4.1 Switching across different exposure levels

# Not used: (ref: https://doi.org/10.1016/j.scitotenv.2020.139383) The hypothesis is that PFAS is not homogeneously distributed in the nutrient solution where roots presented. 
# Water can distribute more efficiently from the solution to the apoplastic area
# Longer-chain PFAS tends go to the distributed water in apoplastic area while shorter-chain PFAS stay in the solution.
# This distribution of PFAS occurs in no time.
# The water uptake speed is faster than the uptake of PFAS, especially for long-chain PFAS

# exposure level 10 μg/L
# C_p[1,] <- C_p*10
# exposure level 1 μg/L
C_s <- C_p*1
# exposure level 0.1 μg/L
# C_p[1,] <- C_p*0.1
# exposure level 0.01 μg/L
# C_p[1,] <- C_p*0.01

# Not used: 4.2 Corrected nutrient solution volume based on actual exposure levels
# Not used: Mass balance: m_solution + m_apoplastic + m_symplastic (m_symplastic includes both the part of PFAS remaining in roots and the part translocated to aboveground)
# Not used: Based on https://doi.org/10.1007/s11356-022-21886-4, we know K_as = 6.26*e^lgKow_i (t = 72h, C_s_ini = 10μg/L) 
# Not used: (K_as = A*e^lgKow_i) & (K_as = C_apo_t/C_s_t) & C_apo_t = (C_s_t-1 - C_s_t)*V_s/M_root to derive: 
# Not used: m_apo_t = C_s_t*M_root_t*A_unit*e^lgKow_i (Cumulative mass) while v_apo_t = C_s_t*M_root_t*A_unit*e^lgKow_i (rate)

# Therefore, we assume a constant 
m_p <- C_s*V_p                                                                  # Determine the total PFAS available for uptake during each irrigation cycle 
Vmax_p_correct <- m_p/m_p*min(m_p/C_s[1,])                                      # Not used, # Select the minimal as corrected volume (Short-chain PFAS which is more water soluble)
V_p_correct <- Vmax_p_correct                                                   # Not used, # Assume corrected volumer = 5.5 L

# 4.3 Adsorption of PFAS to root 
# 4.3.1 Day 1 calculation for solution, root apoplastic, and root symplastic 

# Km represents the "milestone" concentration where the transportation rate reach 1/2 Vmax 
# (Fetilizer etc.,) We observe PFAS concentration in tissues increase linearly when the exposure concentration increase, indicating Km >> C under the exposure range.
# (Ref to be added) Studies indicate that the carrier protein family for active transportation in roots and aboveground phloem are not the same.

Km_apo2sym <- APro_sym*PA_apo*exp(uPro_apo2sym*(lgKow_i - lgKow_i_apo2sym)^2/(2*(B)^2)) 
#Km_apo2sym <- 10000*0.9*exp(0.3*(lgKow_i - 0.23)^2/(2*(1)^2))                  # Unit: ug/kg. Area of cell membrane 1 m^2 

Km_s2sym <- APro_sym*(1-PA_apo)*exp(uPro_s2sym*(lgKow_i - lgKow_i_sym)^2/(2*(B)^2)) 
#Km_s2sym <- 10000*0.1*exp(0.15*(lgKow_i - 1.629)^2/(2*(1)^2))                  # Unit: ug/kg. Area of cell membrane 1 m^2

# (template)Smax_sym[growth + i,] <- A_smax*k_root*i*exp(u_smax*(lgKow_i - lgKow_i_smax)^2/(2*(B_smax)^2))   
# Hypothesis is PFAS in apoplastic area is less available than that in the solution to be transported into symplastic space
# (The review supporting the scarecity of relevant research concerning protein interaction: https://doi.org/10.1016/j.envint.2021.107037)
Smax_sym[1,] <- AS_sym*k_root*1*exp(u_sym*(lgKow_i - lgKow_i_sym))  
# Smax_sym[1,] <- 1000*k_root*1*exp(-0.30*(lgKow_i - 1.629))                    # Though no plant experiments, researchers found carrier protein has maximum affinity with PFAS of C7-C9, namely PFOA, PFNA, PFDA (ref: https://doi.org/10.1093/toxsci/kfp275)

# Calculate C_apo on day 1
v_apo[1,] <- Qday_total[1,]*PQ_apo[1,]*C_s[1,]*M_apo[1,]*exp(u_apo*lgKow_i)  
#v_apo[1,] <- Qday_total[1,]*PQ_apo[1,]*C_s[1,]*M_apo[1,]*exp(1.26*lgKow_i)                                # Derived based on Wang's study (Kd)
m_apo[1,] <- v_apo[1,]                                                          # Cumulative
C_apo[1,] <- m_apo[1,]/M_apo[1,]
m_s[1,] <- m_p[1,] - v_apo[1,]
C_s[1,] <- m_s[1,]/V_p_correct

# S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
S_apo2sym[1,] <- C_apo[1,]*Smax_sym[1,]/(Km_apo2sym + C_apo[1,])
S_s2sym[1,] <- C_s[1,]*Smax_sym[1,]/(Km_s2sym + C_s[1,])

# J is the flux rate of PFAS to symplastic space (μg/kg). 
J_apo2sym[1,] <- S_apo2sym[1,]*M_apo[1,]
J_s2sym[1,] <- S_s2sym[1,]*V_p_correct*ρ_s                                      # V_p_correct*ρ_s represents the mass of solution
J_sym[1,] <- J_apo2sym[1,] + J_s2sym[1,]
m_sym[1,] <- J_sym[1,]                                                          # Cumulative


# 4.2.3.2 Day 2 to Day 8 calculation (circulation)
for (i in 2:8){
  # Adsorption from water by root apoplastic space
  m_apo[i,] <- m_apo[i - 1,] - J_apo2sym[i - 1,]
  m_s[i,] <- m_s[i - 1,] - J_s2sym[i - 1,]
  C_s[i,] <- m_s[i - 1,]/V_p_correct
  v_apo[i,] <- Qday_total[i,]*PQ_apo[i,]*C_s[i,]*M_apo[i,]*exp(u_apo*lgKow_i)
  m_apo[i,] <- v_apo[i,] + m_apo[i - 1,]
  C_apo[i,] <- m_apo[i,]/M_apo[i,]
  m_s[i,] <- m_s[i,] - v_apo[i,]
  C_s[i,] <- m_s[i,]/V_p_correct
  # Cross-membrane transportation via two pathways to root symplastic space
  # Smax depends on lgkow_i and the growth of roots
  Smax_sym[i,] <- AS_sym*k_root*i*exp(u_sym*(lgKow_i -lgKow_i_sym))   
  # S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
  S_apo2sym[i,] <- C_apo[i,]*Smax_sym[i,]/(Km_apo2sym + C_apo[i,])
  S_s2sym[i,] <- C_s[i,]*Smax_sym[i,]/(Km_s2sym + C_s[i,])
  # J is the flux rate of PFAS to symplastic space (μg/kg). 
  J_apo2sym[i,] <- S_apo2sym[i,]*M_apo[i,]
  J_s2sym[i,] <- S_s2sym[i,]*V_p_correct*ρ_s
  J_sym[i,] <- J_apo2sym[i,] + J_s2sym[i,]                                        # non-cumulative
  m_sym[i,] <- J_sym[i,] + m_sym[i - 1,]                                          # Cumulative. Assuming a constant distribution based on weight of plant tissues 
}

# 4.2.3.3 Day 9 to Day 96 calculation, every 8 day a sub-loop

# Day 9-16
# Set spiked soluition refill and create dummy variables. The values will be changed.
C_s[9,] <- C_s[1,]
v_apo[9,] <- Qday_total[9,]*PQ_apo[9,]*C_s[9,]*M_apo[9,]*exp(u_apo*lgKow_i)                            # Derived based on Wang's study (Kd)
m_s[9,] <- C_s[9,]*V_p_correct - v_apo[9,]
C_s[9,] <- m_s[9,]/V_p_correct
m_apo[9,] <- m_apo[8,] - J_apo2sym[8,]
m_apo[9,] <- v_apo[9,] + m_apo[9,]
C_apo[9,] <- m_apo[9,]/M_apo[9,]
Smax_sym[9,] <- AS_sym*k_root*9*exp(u_sym*(lgKow_i -lgKow_i_sym))   
# S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
S_apo2sym[9,] <- C_apo[9,]*Smax_sym[9,]/(Km_apo2sym + C_apo[9,])
S_s2sym[9,] <- C_s[9,]*Smax_sym[9,]/(Km_s2sym + C_s[9,])
# J is the flux rate of PFAS to symplastic space (μg/kg). 
J_apo2sym[9,] <- S_apo2sym[9,]*M_apo[9,]
J_s2sym[9,] <- S_s2sym[9,]*V_p_correct*ρ_s
J_sym[9,] <- J_apo2sym[9,] + J_s2sym[9,]                                        # non-cumulative
m_sym[9,] <- J_sym[9,] + m_sym[8,]                                              # Cumulative. Assuming a constant distribution based on weight of plant tissues 

for (i in 10:16){
  # Adsorption from water by root apoplastic space
  m_apo[i,] <- m_apo[i - 1,] - J_apo2sym[i - 1,]
  m_s[i,] <- m_s[i - 1,] - J_s2sym[i - 1,]
  C_s[i,] <- m_s[i - 1,]/V_p_correct
  v_apo[i,] <- Qday_total[i,]*PQ_apo[i,]*C_s[i,]*M_apo[i,]*exp(u_apo*lgKow_i)
  m_apo[i,] <- v_apo[i,] + m_apo[i - 1,]
  C_apo[i,] <- m_apo[i,]/M_apo[i,]
  m_s[i,] <- m_s[i,] - v_apo[i,]
  C_s[i,] <- m_s[i,]/V_p_correct
  # Cross-membrane transportation via two pathways to root symplastic space
  # Smax depends on lgkow_i and the growth of roots
  Smax_sym[i,] <- AS_sym*k_root*i*exp(u_sym*(lgKow_i -lgKow_i_sym))   
  # S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
  S_apo2sym[i,] <- C_apo[i,]*Smax_sym[i,]/(Km_apo2sym + C_apo[i,])
  S_s2sym[i,] <- C_s[i,]*Smax_sym[i,]/(Km_s2sym + C_s[i,])
  # J is the flux rate of PFAS to symplastic space (μg/kg). 
  J_apo2sym[i,] <- S_apo2sym[i,]*M_apo[i,]
  J_s2sym[i,] <- S_s2sym[i,]*V_p_correct*ρ_s
  J_sym[i,] <- J_apo2sym[i,] + J_s2sym[i,]                                      # non-cumulative
  m_sym[i,] <- J_sym[i,] + m_sym[i - 1,]                                        # Cumulative. Assuming a constant distribution based on weight of plant tissues 
}

# Day 17-24
# Set spiked soluition refill and create dummy variables. The values will be changed.
C_s[17,] <- C_s[1,]
v_apo[17,] <- Qday_total[17,]*PQ_apo[17,]*C_s[17,]*M_apo[17,]*exp(u_apo*lgKow_i)                         # Derived based on Wang's study (Kd)
m_s[17,] <- C_s[17,]*V_p_correct - v_apo[17,]
C_s[17,] <- m_s[17,]/V_p_correct
m_apo[17,] <- m_apo[16,] - J_apo2sym[16,]
m_apo[17,] <- v_apo[17,] + m_apo[17,]
C_apo[17,] <- m_apo[17,]/M_apo[17,]
Smax_sym[17,] <- AS_sym*k_root*17*exp(u_sym*(lgKow_i -lgKow_i_sym))   
# S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
S_apo2sym[17,] <- C_apo[17,]*Smax_sym[17,]/(Km_apo2sym + C_apo[17,])
S_s2sym[17,] <- C_s[17,]*Smax_sym[17,]/(Km_s2sym + C_s[17,])
# J is the flux rate of PFAS to symplastic space (μg/kg). 
J_apo2sym[17,] <- S_apo2sym[17,]*M_apo[17,]
J_s2sym[17,] <- S_s2sym[17,]*V_p_correct*ρ_s
J_sym[17,] <- J_apo2sym[17,] + J_s2sym[17,]                                     # non-cumulative
m_sym[17,] <- J_sym[17,] + m_sym[16,]                                           # Cumulative. Assuming a constant distribution based on weight of plant tissues 

for (i in 18:24){
  # Adsorption from water by root apoplastic space
  m_apo[i,] <- m_apo[i - 1,] - J_apo2sym[i - 1,]
  m_s[i,] <- m_s[i - 1,] - J_s2sym[i - 1,]
  C_s[i,] <- m_s[i - 1,]/V_p_correct
  v_apo[i,] <- Qday_total[i,]*PQ_apo[i,]*C_s[i,]*M_apo[i,]*exp(u_apo*lgKow_i)
  m_apo[i,] <- v_apo[i,] + m_apo[i - 1,]
  C_apo[i,] <- m_apo[i,]/M_apo[i,]
  m_s[i,] <- m_s[i,] - v_apo[i,]
  C_s[i,] <- m_s[i,]/V_p_correct
  # Cross-membrane transportation via two pathways to root symplastic space
  # Smax depends on lgkow_i and the growth of roots
  Smax_sym[i,] <- AS_sym*k_root*i*exp(u_sym*(lgKow_i -lgKow_i_sym))   
  # S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
  S_apo2sym[i,] <- C_apo[i,]*Smax_sym[i,]/(Km_apo2sym + C_apo[i,])
  S_s2sym[i,] <- C_s[i,]*Smax_sym[i,]/(Km_s2sym + C_s[i,])
  # J is the flux rate of PFAS to symplastic space (μg/kg). 
  J_apo2sym[i,] <- S_apo2sym[i,]*M_apo[i,]
  J_s2sym[i,] <- S_s2sym[i,]*V_p_correct*ρ_s
  J_sym[i,] <- J_apo2sym[i,] + J_s2sym[i,]                                        # non-cumulative
  m_sym[i,] <- J_sym[i,] + m_sym[i - 1,]                                          # Cumulative. Assuming a constant distribution based on weight of plant tissues 
}

# Day 25-32
# Set spiked soluition refill and create dummy variables. The values will be changed.
C_s[25,] <- C_s[1,]
v_apo[25,] <- Qday_total[25,]*PQ_apo[25,]*C_s[25,]*M_apo[25,]*exp(u_apo*lgKow_i)                         # Derived based on Wang's study (Kd)
m_s[25,] <- C_s[25,]*V_p_correct - v_apo[25,]
C_s[25,] <- m_s[25,]/V_p_correct
m_apo[25,] <- m_apo[24,] - J_apo2sym[24,]
m_apo[25,] <- v_apo[25,] + m_apo[25,]
C_apo[25,] <- m_apo[25,]/M_apo[25,]
Smax_sym[25,] <- AS_sym*k_root*25*exp(u_sym*(lgKow_i -lgKow_i_sym))   
# S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
S_apo2sym[25,] <- C_apo[25,]*Smax_sym[25,]/(Km_apo2sym + C_apo[25,])
S_s2sym[25,] <- C_s[25,]*Smax_sym[25,]/(Km_s2sym + C_s[25,])
# J is the flux rate of PFAS to symplastic space (μg/kg). 
J_apo2sym[25,] <- S_apo2sym[25,]*M_apo[25,]
J_s2sym[25,] <- S_s2sym[25,]*V_p_correct*ρ_s
J_sym[25,] <- J_apo2sym[25,] + J_s2sym[25,]                                     # non-cumulative
m_sym[25,] <- J_sym[25,] + m_sym[24,]                                           # Cumulative. Assuming a constant distribution based on weight of plant tissues 

for (i in 26:32){
  # Adsorption from water by root apoplastic space
  m_apo[i,] <- m_apo[i - 1,] - J_apo2sym[i - 1,]
  m_s[i,] <- m_s[i - 1,] - J_s2sym[i - 1,]
  C_s[i,] <- m_s[i - 1,]/V_p_correct
  v_apo[i,] <- Qday_total[i,]*PQ_apo[i,]*C_s[i,]*M_apo[i,]*exp(u_apo*lgKow_i)
  m_apo[i,] <- v_apo[i,] + m_apo[i - 1,]
  C_apo[i,] <- m_apo[i,]/M_apo[i,]
  m_s[i,] <- m_s[i,] - v_apo[i,]
  C_s[i,] <- m_s[i,]/V_p_correct
  # Cross-membrane transportation via two pathways to root symplastic space
  # Smax depends on lgkow_i and the growth of roots
  Smax_sym[i,] <- AS_sym*k_root*i*exp(u_sym*(lgKow_i -lgKow_i_sym))   
  # S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
  S_apo2sym[i,] <- C_apo[i,]*Smax_sym[i,]/(Km_apo2sym + C_apo[i,])
  S_s2sym[i,] <- C_s[i,]*Smax_sym[i,]/(Km_s2sym + C_s[i,])
  # J is the flux rate of PFAS to symplastic space (μg/kg). 
  J_apo2sym[i,] <- S_apo2sym[i,]*M_apo[i,]
  J_s2sym[i,] <- S_s2sym[i,]*V_p_correct*ρ_s
  J_sym[i,] <- J_apo2sym[i,] + J_s2sym[i,]                                        # non-cumulative
  m_sym[i,] <- J_sym[i,] + m_sym[i - 1,]                                          # Cumulative. Assuming a constant distribution based on weight of plant tissues 
}

# Day 33 - 40
# Set spiked soluition refill and create dummy variables. The values will be changed.
C_s[33,] <- C_s[1,]
v_apo[33,] <- Qday_total[33,]*PQ_apo[33,]*C_s[33,]*M_apo[33,]*exp(u_apo*lgKow_i)                         # Derived based on Wang's study (Kd)
m_s[33,] <- C_s[33,]*V_p_correct - v_apo[33,]
C_s[33,] <- m_s[33,]/V_p_correct
m_apo[33,] <- m_apo[32,] - J_apo2sym[32,]
m_apo[33,] <- v_apo[33,] + m_apo[33,]
C_apo[33,] <- m_apo[33,]/M_apo[33,]
Smax_sym[33,] <- AS_sym*k_root*33*exp(u_sym*(lgKow_i -lgKow_i_sym))   
# S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
S_apo2sym[33,] <- C_apo[33,]*Smax_sym[33,]/(Km_apo2sym + C_apo[33,])
S_s2sym[33,] <- C_s[33,]*Smax_sym[33,]/(Km_s2sym + C_s[33,])
# J is the flux rate of PFAS to symplastic space (μg/kg). 
J_apo2sym[33,] <- S_apo2sym[33,]*M_apo[33,]
J_s2sym[33,] <- S_s2sym[33,]*V_p_correct*ρ_s
J_sym[33,] <- J_apo2sym[33,] + J_s2sym[33,]                                     # non-cumulative
m_sym[33,] <- J_sym[33,] + m_sym[32,]                                           # Cumulative. Assuming a constant distribution based on weight of plant tissues 

for (i in 34:40){
  # Adsorption from water by root apoplastic space
  m_apo[i,] <- m_apo[i - 1,] - J_apo2sym[i - 1,]
  m_s[i,] <- m_s[i - 1,] - J_s2sym[i - 1,]
  C_s[i,] <- m_s[i - 1,]/V_p_correct
  v_apo[i,] <- Qday_total[i,]*PQ_apo[i,]*C_s[i,]*M_apo[i,]*exp(u_apo*lgKow_i)
  m_apo[i,] <- v_apo[i,] + m_apo[i - 1,]
  C_apo[i,] <- m_apo[i,]/M_apo[i,]
  m_s[i,] <- m_s[i,] - v_apo[i,]
  C_s[i,] <- m_s[i,]/V_p_correct
  # Cross-membrane transportation via two pathways to root symplastic space
  # Smax depends on lgkow_i and the growth of roots
  Smax_sym[i,] <- AS_sym*k_root*i*exp(u_sym*(lgKow_i -lgKow_i_sym))   
  # S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
  S_apo2sym[i,] <- C_apo[i,]*Smax_sym[i,]/(Km_apo2sym + C_apo[i,])
  S_s2sym[i,] <- C_s[i,]*Smax_sym[i,]/(Km_s2sym + C_s[i,])
  # J is the flux rate of PFAS to symplastic space (μg/kg). 
  J_apo2sym[i,] <- S_apo2sym[i,]*M_apo[i,]
  J_s2sym[i,] <- S_s2sym[i,]*V_p_correct*ρ_s
  J_sym[i,] <- J_apo2sym[i,] + J_s2sym[i,]                                        # non-cumulative
  m_sym[i,] <- J_sym[i,] + m_sym[i - 1,]                                          # Cumulative. Assuming a constant distribution based on weight of plant tissues 
}
# Day 41 - 48
# Set spiked soluition refill and create dummy variables. The values will be changed.
C_s[41,] <- C_s[1,]
v_apo[41,] <- Qday_total[41,]*PQ_apo[41,]*C_s[41,]*M_apo[41,]*exp(u_apo*lgKow_i)                         # Derived based on Wang's study (Kd)
m_s[41,] <- C_s[41,]*V_p_correct - v_apo[41,]
C_s[41,] <- m_s[41,]/V_p_correct
m_apo[41,] <- m_apo[40,] - J_apo2sym[40,]
m_apo[41,] <- v_apo[41,] + m_apo[41,]
C_apo[41,] <- m_apo[41,]/M_apo[41,]
Smax_sym[41,] <- AS_sym*k_root*41*exp(u_sym*(lgKow_i -lgKow_i_sym))   
# S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
S_apo2sym[41,] <- C_apo[41,]*Smax_sym[41,]/(Km_apo2sym + C_apo[41,])
S_s2sym[41,] <- C_s[41,]*Smax_sym[41,]/(Km_s2sym + C_s[41,])
# J is the flux rate of PFAS to symplastic space (μg/kg). 
J_apo2sym[41,] <- S_apo2sym[41,]*M_apo[41,]
J_s2sym[41,] <- S_s2sym[41,]*V_p_correct*ρ_s
J_sym[41,] <- J_apo2sym[41,] + J_s2sym[41,]                                     # non-cumulative
m_sym[41,] <- J_sym[41,] + m_sym[40,]                                           # Cumulative. Assuming a constant distribution based on weight of plant tissues 

for (i in 42:48){
  # Adsorption from water by root apoplastic space
  m_apo[i,] <- m_apo[i - 1,] - J_apo2sym[i - 1,]
  m_s[i,] <- m_s[i - 1,] - J_s2sym[i - 1,]
  C_s[i,] <- m_s[i - 1,]/V_p_correct
  v_apo[i,] <- Qday_total[i,]*PQ_apo[i,]*C_s[i,]*M_apo[i,]*exp(u_apo*lgKow_i)
  m_apo[i,] <- v_apo[i,] + m_apo[i - 1,]
  C_apo[i,] <- m_apo[i,]/M_apo[i,]
  m_s[i,] <- m_s[i,] - v_apo[i,]
  C_s[i,] <- m_s[i,]/V_p_correct
  # Cross-membrane transportation via two pathways to root symplastic space
  # Smax depends on lgkow_i and the growth of roots
  Smax_sym[i,] <- AS_sym*k_root*i*exp(u_sym*(lgKow_i -lgKow_i_sym))   
  # S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
  S_apo2sym[i,] <- C_apo[i,]*Smax_sym[i,]/(Km_apo2sym + C_apo[i,])
  S_s2sym[i,] <- C_s[i,]*Smax_sym[i,]/(Km_s2sym + C_s[i,])
  # J is the flux rate of PFAS to symplastic space (μg/kg). 
  J_apo2sym[i,] <- S_apo2sym[i,]*M_apo[i,]
  J_s2sym[i,] <- S_s2sym[i,]*V_p_correct*ρ_s
  J_sym[i,] <- J_apo2sym[i,] + J_s2sym[i,]                                        # non-cumulative
  m_sym[i,] <- J_sym[i,] + m_sym[i - 1,]                                          # Cumulative. Assuming a constant distribution based on weight of plant tissues 
}
# Day 49 - 56
# Set spiked soluition refill and create dummy variables. The values will be changed.
C_s[49,] <- C_s[1,]
v_apo[49,] <- Qday_total[49,]*PQ_apo[49,]*C_s[49,]*M_apo[49,]*exp(u_apo*lgKow_i)                         # Derived based on Wang's study (Kd)
m_s[49,] <- C_s[49,]*V_p_correct - v_apo[49,]
C_s[49,] <- m_s[49,]/V_p_correct
m_apo[49,] <- m_apo[48,] - J_apo2sym[48,]
m_apo[49,] <- v_apo[49,] + m_apo[49,]
C_apo[49,] <- m_apo[49,]/M_apo[49,]
Smax_sym[49,] <- AS_sym*k_root*49*exp(u_sym*(lgKow_i -lgKow_i_sym))   
# S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
S_apo2sym[49,] <- C_apo[49,]*Smax_sym[49,]/(Km_apo2sym + C_apo[49,])
S_s2sym[49,] <- C_s[49,]*Smax_sym[49,]/(Km_s2sym + C_s[49,])
# J is the flux rate of PFAS to symplastic space (μg/kg). 
J_apo2sym[49,] <- S_apo2sym[49,]*M_apo[49,]
J_s2sym[49,] <- S_s2sym[49,]*V_p_correct*ρ_s
J_sym[49,] <- J_apo2sym[49,] + J_s2sym[49,]                                     # non-cumulative
m_sym[49,] <- J_sym[49,] + m_sym[48,]                                           # Cumulative. Assuming a constant distribution based on weight of plant tissues 

for (i in 50:56){
  # Adsorption from water by root apoplastic space
  m_apo[i,] <- m_apo[i - 1,] - J_apo2sym[i - 1,]
  m_s[i,] <- m_s[i - 1,] - J_s2sym[i - 1,]
  C_s[i,] <- m_s[i - 1,]/V_p_correct
  v_apo[i,] <- Qday_total[i,]*PQ_apo[i,]*C_s[i,]*M_apo[i,]*exp(u_apo*lgKow_i)
  m_apo[i,] <- v_apo[i,] + m_apo[i - 1,]
  C_apo[i,] <- m_apo[i,]/M_apo[i,]
  m_s[i,] <- m_s[i,] - v_apo[i,]
  C_s[i,] <- m_s[i,]/V_p_correct
  # Cross-membrane transportation via two pathways to root symplastic space
  # Smax depends on lgkow_i and the growth of roots
  Smax_sym[i,] <- AS_sym*k_root*i*exp(u_sym*(lgKow_i -lgKow_i_sym))   
  # S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
  S_apo2sym[i,] <- C_apo[i,]*Smax_sym[i,]/(Km_apo2sym + C_apo[i,])
  S_s2sym[i,] <- C_s[i,]*Smax_sym[i,]/(Km_s2sym + C_s[i,])
  # J is the flux rate of PFAS to symplastic space (μg/kg). 
  J_apo2sym[i,] <- S_apo2sym[i,]*M_apo[i,]
  J_s2sym[i,] <- S_s2sym[i,]*V_p_correct*ρ_s
  J_sym[i,] <- J_apo2sym[i,] + J_s2sym[i,]                                        # non-cumulative
  m_sym[i,] <- J_sym[i,] + m_sym[i - 1,]                                          # Cumulative. Assuming a constant distribution based on weight of plant tissues 
}
# Day 57 - 64
# Set spiked soluition refill and create dummy variables. The values will be changed.
C_s[57,] <- C_s[1,]
v_apo[57,] <- Qday_total[57,]*PQ_apo[57,]*C_s[57,]*M_apo[57,]*exp(u_apo*lgKow_i)                         # Derived based on Wang's study (Kd)
m_s[57,] <- C_s[57,]*V_p_correct - v_apo[57,]
C_s[57,] <- m_s[57,]/V_p_correct
m_apo[57,] <- m_apo[56,] - J_apo2sym[56,]
m_apo[57,] <- v_apo[57,] + m_apo[57,]
C_apo[57,] <- m_apo[57,]/M_apo[57,]
Smax_sym[57,] <- AS_sym*k_root*57*exp(u_sym*(lgKow_i -lgKow_i_sym))   
# S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
S_apo2sym[57,] <- C_apo[57,]*Smax_sym[57,]/(Km_apo2sym + C_apo[57,])
S_s2sym[57,] <- C_s[57,]*Smax_sym[57,]/(Km_s2sym + C_s[57,])
# J is the flux rate of PFAS to symplastic space (μg/kg). 
J_apo2sym[57,] <- S_apo2sym[57,]*M_apo[57,]
J_s2sym[57,] <- S_s2sym[57,]*V_p_correct*ρ_s
J_sym[57,] <- J_apo2sym[57,] + J_s2sym[57,]                                     # non-cumulative
m_sym[57,] <- J_sym[57,] + m_sym[56,]                                           # Cumulative. Assuming a constant distribution based on weight of plant tissues 

for (i in 58:64){
  # Adsorption from water by root apoplastic space
  m_apo[i,] <- m_apo[i - 1,] - J_apo2sym[i - 1,]
  m_s[i,] <- m_s[i - 1,] - J_s2sym[i - 1,]
  C_s[i,] <- m_s[i - 1,]/V_p_correct
  v_apo[i,] <- Qday_total[i,]*PQ_apo[i,]*C_s[i,]*M_apo[i,]*exp(u_apo*lgKow_i)
  m_apo[i,] <- v_apo[i,] + m_apo[i - 1,]
  C_apo[i,] <- m_apo[i,]/M_apo[i,]
  m_s[i,] <- m_s[i,] - v_apo[i,]
  C_s[i,] <- m_s[i,]/V_p_correct
  # Cross-membrane transportation via two pathways to root symplastic space
  # Smax depends on lgkow_i and the growth of roots
  Smax_sym[i,] <- AS_sym*k_root*i*exp(u_sym*(lgKow_i -lgKow_i_sym))   
  # S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
  S_apo2sym[i,] <- C_apo[i,]*Smax_sym[i,]/(Km_apo2sym + C_apo[i,])
  S_s2sym[i,] <- C_s[i,]*Smax_sym[i,]/(Km_s2sym + C_s[i,])
  # J is the flux rate of PFAS to symplastic space (μg/kg). 
  J_apo2sym[i,] <- S_apo2sym[i,]*M_apo[i,]
  J_s2sym[i,] <- S_s2sym[i,]*V_p_correct*ρ_s
  J_sym[i,] <- J_apo2sym[i,] + J_s2sym[i,]                                        # non-cumulative
  m_sym[i,] <- J_sym[i,] + m_sym[i - 1,]                                          # Cumulative. Assuming a constant distribution based on weight of plant tissues 
}
# Day 65 - 72
# Set spiked soluition refill and create dummy variables. The values will be changed.
C_s[65,] <- C_s[1,]
v_apo[65,] <- Qday_total[65,]*PQ_apo[65,]*C_s[65,]*M_apo[65,]*exp(u_apo*lgKow_i)                         # Derived based on Wang's study (Kd)
m_s[65,] <- C_s[65,]*V_p_correct - v_apo[65,]
C_s[65,] <- m_s[65,]/V_p_correct
m_apo[65,] <- m_apo[64,] - J_apo2sym[64,]
m_apo[65,] <- v_apo[65,] + m_apo[65,]
C_apo[65,] <- m_apo[65,]/M_apo[65,]
Smax_sym[65,] <- AS_sym*k_root*65*exp(u_sym*(lgKow_i -lgKow_i_sym))   
# S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
S_apo2sym[65,] <- C_apo[65,]*Smax_sym[65,]/(Km_apo2sym + C_apo[65,])
S_s2sym[65,] <- C_s[65,]*Smax_sym[65,]/(Km_s2sym + C_s[65,])
# J is the flux rate of PFAS to symplastic space (μg/kg). 
J_apo2sym[65,] <- S_apo2sym[65,]*M_apo[65,]
J_s2sym[65,] <- S_s2sym[65,]*V_p_correct*ρ_s
J_sym[65,] <- J_apo2sym[65,] + J_s2sym[65,]                                     # non-cumulative
m_sym[65,] <- J_sym[65,] + m_sym[64,]                                           # Cumulative. Assuming a constant distribution based on weight of plant tissues 

for (i in 66:72){
  # Adsorption from water by root apoplastic space
  m_apo[i,] <- m_apo[i - 1,] - J_apo2sym[i - 1,]
  m_s[i,] <- m_s[i - 1,] - J_s2sym[i - 1,]
  C_s[i,] <- m_s[i - 1,]/V_p_correct
  v_apo[i,] <- Qday_total[i,]*PQ_apo[i,]*C_s[i,]*M_apo[i,]*exp(u_apo*lgKow_i)
  m_apo[i,] <- v_apo[i,] + m_apo[i - 1,]
  C_apo[i,] <- m_apo[i,]/M_apo[i,]
  m_s[i,] <- m_s[i,] - v_apo[i,]
  C_s[i,] <- m_s[i,]/V_p_correct
  # Cross-membrane transportation via two pathways to root symplastic space
  # Smax depends on lgkow_i and the growth of roots
  Smax_sym[i,] <- AS_sym*k_root*i*exp(u_sym*(lgKow_i -lgKow_i_sym))   
  # S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
  S_apo2sym[i,] <- C_apo[i,]*Smax_sym[i,]/(Km_apo2sym + C_apo[i,])
  S_s2sym[i,] <- C_s[i,]*Smax_sym[i,]/(Km_s2sym + C_s[i,])
  # J is the flux rate of PFAS to symplastic space (μg/kg). 
  J_apo2sym[i,] <- S_apo2sym[i,]*M_apo[i,]
  J_s2sym[i,] <- S_s2sym[i,]*V_p_correct*ρ_s
  J_sym[i,] <- J_apo2sym[i,] + J_s2sym[i,]                                        # non-cumulative
  m_sym[i,] <- J_sym[i,] + m_sym[i - 1,]                                          # Cumulative. Assuming a constant distribution based on weight of plant tissues 
}
# Day 73 - 80
# Set spiked soluition refill and create dummy variables. The values will be changed.
C_s[73,] <- C_s[1,]
v_apo[73,] <- Qday_total[73,]*PQ_apo[73,]*C_s[73,]*M_apo[73,]*exp(u_apo*lgKow_i)                         # Derived based on Wang's study (Kd)
m_s[73,] <- C_s[73,]*V_p_correct - v_apo[73,]
C_s[73,] <- m_s[73,]/V_p_correct
m_apo[73,] <- m_apo[72,] - J_apo2sym[72,]
m_apo[73,] <- v_apo[73,] + m_apo[73,]
C_apo[73,] <- m_apo[73,]/M_apo[73,]
Smax_sym[73,] <- AS_sym*k_root*73*exp(u_sym*(lgKow_i -lgKow_i_sym))   
# S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
S_apo2sym[73,] <- C_apo[73,]*Smax_sym[73,]/(Km_apo2sym + C_apo[73,])
S_s2sym[73,] <- C_s[73,]*Smax_sym[73,]/(Km_s2sym + C_s[73,])
# J is the flux rate of PFAS to symplastic space (μg/kg). 
J_apo2sym[73,] <- S_apo2sym[73,]*M_apo[73,]
J_s2sym[73,] <- S_s2sym[73,]*V_p_correct*ρ_s
J_sym[73,] <- J_apo2sym[73,] + J_s2sym[73,]                                     # non-cumulative
m_sym[73,] <- J_sym[73,] + m_sym[72,]                                           # Cumulative. Assuming a constant distribution based on weight of plant tissues 

for (i in 74:80){
  # Adsorption from water by root apoplastic space
  m_apo[i,] <- m_apo[i - 1,] - J_apo2sym[i - 1,]
  m_s[i,] <- m_s[i - 1,] - J_s2sym[i - 1,]
  C_s[i,] <- m_s[i - 1,]/V_p_correct
  v_apo[i,] <- Qday_total[i,]*PQ_apo[i,]*C_s[i,]*M_apo[i,]*exp(u_apo*lgKow_i)
  m_apo[i,] <- v_apo[i,] + m_apo[i - 1,]
  C_apo[i,] <- m_apo[i,]/M_apo[i,]
  m_s[i,] <- m_s[i,] - v_apo[i,]
  C_s[i,] <- m_s[i,]/V_p_correct
  # Cross-membrane transportation via two pathways to root symplastic space
  # Smax depends on lgkow_i and the growth of roots
  Smax_sym[i,] <- AS_sym*k_root*i*exp(u_sym*(lgKow_i -lgKow_i_sym))   
  # S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
  S_apo2sym[i,] <- C_apo[i,]*Smax_sym[i,]/(Km_apo2sym + C_apo[i,])
  S_s2sym[i,] <- C_s[i,]*Smax_sym[i,]/(Km_s2sym + C_s[i,])
  # J is the flux rate of PFAS to symplastic space (μg/kg). 
  J_apo2sym[i,] <- S_apo2sym[i,]*M_apo[i,]
  J_s2sym[i,] <- S_s2sym[i,]*V_p_correct*ρ_s
  J_sym[i,] <- J_apo2sym[i,] + J_s2sym[i,]                                        # non-cumulative
  m_sym[i,] <- J_sym[i,] + m_sym[i - 1,]                                          # Cumulative. Assuming a constant distribution based on weight of plant tissues 
}
# Day 81 - 88
# Set spiked soluition refill and create dummy variables. The values will be changed.
C_s[81,] <- C_s[1,]
v_apo[81,] <- Qday_total[81,]*PQ_apo[81,]*C_s[81,]*M_apo[81,]*exp(u_apo*lgKow_i)                         # Derived based on Wang's study (Kd)
m_s[81,] <- C_s[81,]*V_p_correct - v_apo[81,]
C_s[81,] <- m_s[81,]/V_p_correct
m_apo[81,] <- m_apo[80,] - J_apo2sym[80,]
m_apo[81,] <- v_apo[81,] + m_apo[81,]
C_apo[81,] <- m_apo[81,]/M_apo[81,]
Smax_sym[81,] <- AS_sym*k_root*81*exp(u_sym*(lgKow_i -lgKow_i_sym))   
# S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
S_apo2sym[81,] <- C_apo[81,]*Smax_sym[81,]/(Km_apo2sym + C_apo[81,])
S_s2sym[81,] <- C_s[81,]*Smax_sym[81,]/(Km_s2sym + C_s[81,])
# J is the flux rate of PFAS to symplastic space (μg/kg). 
J_apo2sym[81,] <- S_apo2sym[81,]*M_apo[81,]
J_s2sym[81,] <- S_s2sym[81,]*V_p_correct*ρ_s
J_sym[81,] <- J_apo2sym[81,] + J_s2sym[81,]                                     # non-cumulative
m_sym[81,] <- J_sym[81,] + m_sym[80,]                                           # Cumulative. Assuming a constant distribution based on weight of plant tissues 

for (i in 82:88){
  # Adsorption from water by root apoplastic space
  m_apo[i,] <- m_apo[i - 1,] - J_apo2sym[i - 1,]
  m_s[i,] <- m_s[i - 1,] - J_s2sym[i - 1,]
  C_s[i,] <- m_s[i - 1,]/V_p_correct
  v_apo[i,] <- Qday_total[i,]*PQ_apo[i,]*C_s[i,]*M_apo[i,]*exp(u_apo*lgKow_i)
  m_apo[i,] <- v_apo[i,] + m_apo[i - 1,]
  C_apo[i,] <- m_apo[i,]/M_apo[i,]
  m_s[i,] <- m_s[i,] - v_apo[i,]
  C_s[i,] <- m_s[i,]/V_p_correct
  # Cross-membrane transportation via two pathways to root symplastic space
  # Smax depends on lgkow_i and the growth of roots
  Smax_sym[i,] <- AS_sym*k_root*i*exp(u_sym*(lgKow_i -lgKow_i_sym))   
  # S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
  S_apo2sym[i,] <- C_apo[i,]*Smax_sym[i,]/(Km_apo2sym + C_apo[i,])
  S_s2sym[i,] <- C_s[i,]*Smax_sym[i,]/(Km_s2sym + C_s[i,])
  # J is the flux rate of PFAS to symplastic space (μg/kg). 
  J_apo2sym[i,] <- S_apo2sym[i,]*M_apo[i,]
  J_s2sym[i,] <- S_s2sym[i,]*V_p_correct*ρ_s
  J_sym[i,] <- J_apo2sym[i,] + J_s2sym[i,]                                        # non-cumulative
  m_sym[i,] <- J_sym[i,] + m_sym[i - 1,]                                          # Cumulative. Assuming a constant distribution based on weight of plant tissues 
}
# Day 89 - 96
# Set spiked solution refill and create dummy variables. The values will be changed.
C_s[89,] <- C_s[1,]
v_apo[89,] <- Qday_total[89,]*PQ_apo[89,]*C_s[89,]*M_apo[89,]*exp(u_apo*lgKow_i)                         # Derived based on Wang's study (Kd)
m_s[89,] <- C_s[89,]*V_p_correct - v_apo[89,]
C_s[89,] <- m_s[89,]/V_p_correct
m_apo[89,] <- m_apo[88,] - J_apo2sym[88,]
m_apo[89,] <- v_apo[89,] + m_apo[89,]
C_apo[89,] <- m_apo[89,]/M_apo[89,]
Smax_sym[89,] <- AS_sym*k_root*89*exp(u_sym*(lgKow_i -lgKow_i_sym))   
# S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
S_apo2sym[89,] <- C_apo[89,]*Smax_sym[89,]/(Km_apo2sym + C_apo[89,])
S_s2sym[89,] <- C_s[89,]*Smax_sym[89,]/(Km_s2sym + C_s[89,])
# J is the flux rate of PFAS to symplastic space (μg/kg). 
J_apo2sym[89,] <- S_apo2sym[89,]*M_apo[89,]
J_s2sym[89,] <- S_s2sym[89,]*V_p_correct*ρ_s
J_sym[89,] <- J_apo2sym[89,] + J_s2sym[89,]                                     # non-cumulative
m_sym[89,] <- J_sym[89,] + m_sym[88,]                                           # Cumulative. Assuming a constant distribution based on weight of plant tissues 

for (i in 90:96){
  # Adsorption from water by root apoplastic space
  m_apo[i,] <- m_apo[i - 1,] - J_apo2sym[i - 1,]
  m_s[i,] <- m_s[i - 1,] - J_s2sym[i - 1,]
  C_s[i,] <- m_s[i - 1,]/V_p_correct
  v_apo[i,] <- Qday_total[i,]*PQ_apo[i,]*C_s[i,]*M_apo[i,]*exp(u_apo*lgKow_i)
  m_apo[i,] <- v_apo[i,] + m_apo[i - 1,]
  C_apo[i,] <- m_apo[i,]/M_apo[i,]
  m_s[i,] <- m_s[i,] - v_apo[i,]
  C_s[i,] <- m_s[i,]/V_p_correct
  # Cross-membrane transportation via two pathways to root symplastic space
  # Smax depends on lgkow_i and the growth of roots
  Smax_sym[i,] <- AS_sym*k_root*i*exp(u_sym*(lgKow_i -lgKow_i_sym))   
  # S is the rate of PFAS to symplatic per kg root biomass (μg/kg/day), so it's easy to populate for different plants
  S_apo2sym[i,] <- C_apo[i,]*Smax_sym[i,]/(Km_apo2sym + C_apo[i,])
  S_s2sym[i,] <- C_s[i,]*Smax_sym[i,]/(Km_s2sym + C_s[i,])
  # J is the flux rate of PFAS to symplastic space (μg/kg). 
  J_apo2sym[i,] <- S_apo2sym[i,]*M_apo[i,]
  J_s2sym[i,] <- S_s2sym[i,]*V_p_correct*ρ_s
  J_sym[i,] <- J_apo2sym[i,] + J_s2sym[i,]                                      # non-cumulative
  m_sym[i,] <- J_sym[i,] + m_sym[i - 1,]                                        # Cumulative. Assuming a constant distribution based on weight of plant tissues 
}

# Correct unit of concentration for transpiration-driven translocation 
Percent_Qday <- V_above/(V_sym + V_above)                                       # Percentage of water leave root symplastic space per day

m_sym_root <- m_sym*(1 - Percent_Qday)                                          # PFAS Proportion stay in roots 
m_sym_above <- m_sym*Percent_Qday                                               # PFAS Proportion translocate to the aboveground

# final calculation for roots
C_root <- (m_apo + m_sym_root)/M_root

# PFAS Concentration in "Source" for the aboveground, leaves & fruits are "Sink"
C_symL <- m_sym_above/Qday_total

# 4.2.2 Soil context calculation - To Be Added

# 4.3 translocation of PFAS from roots to aboveground parts
# I assume upward translocation is driven by plant transpiration.The water movement from outer roots to symplastic/casparian strips will drive movement of PFAS in both symplastic and apoplastic pathways.

# 4.3.1 Adsorption to stems & twigs during transportation within aboveground parts
# Calculate the residual mass of PFAS in stems
Kad_stem <- Aad_stem*exp(uad_stem*(lgKow_i - lgKow_i_stem)) 
#Kad_stem <- 0.0002*exp(0.99*(lgKow_i - 0.752))

Kad_stem <- Kad_stem[rep(1,harvest),,drop = FALSE] # Drop to regulate R to not simplify it from data frame to vector

m_stem[1,] <- Kad_stem[1,]*L_stem[1,]*C_symL[1,]
for (i in 2:harvest){
  m_stem[i,] <- Kad_stem[i,]*L_stem[i,]*C_symL[i,] + m_stem[i - 1,]             # Cumulative
}
C_stem <- m_stem/M_stem

# Calculate the residual mass of PFAS in twigsXY
Kad_twigXY <- Aad_twigXY*exp(uad_twigXY*(lgKow_i - lgKow_i_twigXY))             
#Kad_twigXY <- 0.0002*exp(0.49*(lgKow_i - 0.752))

Kad_twigXY <- Kad_twigXY[rep(1,harvest),,drop = FALSE] # Drop to regulate R to not simplify it from data frame to vector

m_twig[1,] <- Kad_twigXY[1,]*L_twig[1,]*C_symL[1,]
for (i in 2:harvest){
  m_twig[i,] <- Kad_twigXY[i,]*L_twig[i,]*C_symL[i,] + m_twig[i - 1,]           # Cumulative
}
C_twig <- m_twig/M_twig

# 4.3.2 The total amount of PFAS into the aboveground parts of plants (μg) and distribution in leaves and fruits
# PFAS Mass in fruits via xylem, without yet considering the remaining parts in different tissues and phloem transportation
for (i in 1:harvest){
  m_fruit[i,] <- (m_sym_above[i,] - m_twig[i,] - m_stem[i,])*RQ_fruit
}

# PFAS concentration in fruits when only considering xylem transportation
C_fruit <- m_fruit/M_fruit
# Corrected Nah values
for (i in 1:growth){
  C_fruit[i,] <- 0*i
}

# 4.3.5 PFAS mass transported to leaves after adsorption via xylem, based on mass balance
# The mass of PFAS in leaves during the growth period (NO fruits, nor twigPH)
for (i in 1:growth){
  m_leaf[i,] <- m_sym_above[i,] - m_stem[i,] - m_twig[i,]
  C_leaf[i,] <- m_leaf[i,]/M_leaf[i,]
}
# Create a dummy variable for m_leaf
for (i in 1:fruiting){
  m_leaf[growth + i,] <- m_sym_above[growth + i,] - m_stem[growth + i,] - m_twig[growth + i,] - m_fruit[growth + i,]
  C_leaf[growth + i,] <- m_leaf[growth + i,]/M_leaf[growth + i,]
}

# 4.3.7 Phloem transportation: among twigs, leaves, and fruits.(Dominant based on ref: https://doi.org/10.1111/j.1438-8677.1987.tb02008.x; + more literature to support)
# The unit of v_fruit is set to be μg/day, hence v_fruit = mph_fruit

# Km represents the "milestone" concentration where the transportation rate reach 1/2 Vmax 
# (Fetilizer etc.,) We observe PFAS concentration in tissues increase linearly when the exposure concentration increase, indicating Km >> C under the exposure range.
# (Ref to be searched) Studies indicate that the carrier protein family for active transportation in roots and aboveground phloem are not the same.

Km_ph <- APro_ph*exp(uPro_ph*(lgKow_i - lgKow_i_ph)^2/(2*(B)^2))            # Longer chain, higher Km, less tendency to bind to the carrier protein.(Ref: https://doi.org/10.1016/j.envint.2019.105324;) Empirical results show C_fruit has a peak at PFPeA  
#Km_ph <- 10000*exp(0.55*(lgKow_i -0.23)^2/(2*(1)^2)) 

Kad_twigPH <- Aad_twigPH*exp(uad_twigPH*(lgKow_i - lgKow_i_twigPH))                     
#Kad_twigPH <- 0.0004*exp(0.005*(lgKow_i - 1.79))                                 # 0.01 because the substances are no longer distributing freely but with carrier protein, this also influence the turning point.


# Create dummy variables
for (i in 1:harvest){
  dC_ph[i,] <- 0*i                                                              # Create empty rows
  Smax_ph[i,] <- 0*i                                                            # Create empty rows
  J_fruit[i,] <- 0*i                                                            # Create empty rows
  S_ph[i,] <- 0*i                                                               # Create empty rows
  v_twigPH[i,] <- 0*i                                                           # Create empty rows
}

# Smax depends on lgkow_i, derived based on empirical observation
#1000*k_fruit*i*exp(-0.3*(lgKow_i - 0.23))

# (The review supporting the scarecity of relevant research concerning protein interaction: https://doi.org/10.1016/j.envint.2021.107037)

for (i in 1: fruiting){
  dC_ph[growth + i,] <- m_leaf[growth + i - 1,]/M_leaf[growth + i - 1,] - C_fruit[growth + i - 1,]
  Smax_ph[growth + i,] <- AS_ph*k_fruit*i*exp(u_ph*(lgKow_i - lgKow_i_ph))
  #Smax_ph[growth + i,] <- 1000*k_fruit*i*exp(-0.3*(lgKow_i - 0.23))
  # S is the rate of PFAS to fruits per kg fruit biomass per day (μg/kg/day), so it's easy to populate for different plants
  S_ph[growth + i,] <- (dC_ph[growth + i,]*Smax_ph[growth + i,])/(Km_ph + dC_ph[growth + i,])
  # J is the flux rate of PFAS to fruits from leaves per day (μg/kg). 
  J_fruit[growth + i,] <- S_ph[growth + i,]*M_leaf[growth + i,]
  # v is the adsorption rate of PFAS to the twigs due to phloem transportation per day (μg/kg)
  v_twigPH[growth + i,] <- Kad_twigPH*L_twig[growth + i,]*dC_ph[growth + i,]
  m_fruit[growth + i,] <- J_fruit[growth + i,] + m_fruit[growth + i - 1,] - v_twigPH[growth + i,]  # ref: https://doi.org/10.1016/j.envpol.2017.16 using the same equation describing active transportation in roots
  C_fruit[growth + i,] <- m_fruit[growth + i,]/M_fruit[growth + i,]
  m_twig[growth + i,] <-  v_twigPH[growth + i,] + m_twig[growth + i - 1,]
  C_twig[growth + i,] <- m_twig[growth + i,]/(M_twig[growth + i,])
  m_leaf[growth + i,] <- m_sym_above[growth + i,] - m_stem[growth + i,] - m_twig[growth + i,] - m_fruit[growth + i,] 
}

# Update C_leaf concentration based on the residual PFAS in leaf
C_leaf <- m_leaf/M_leaf


# 5. Plotting for deterministic prediction

# Package loading
library(readxl)
library(ggplot2)
library(tidyr)
library(patchwork)

# 5.1 Import results
Substance <- c("PFBA","PFPeA","PFHxA","PFHpA","PFOA","PFNA","PFDA","PFUnA")
columnize <- function(input){
  # make tibble/data.frame a vector so we can create a result overview for plotting
  input <- as.numeric(input)
}

N_carbon <- c(3:10)
C_spw <- c(rep(1,8))
lgKow_i_plot <- round(columnize(lgKow_i), digits = 3)
C_root_plot <- columnize(C_root[harvest,])
C_stem_plot <- columnize(C_stem[harvest,])
C_twig_plot <- columnize(C_twig[harvest,])
C_leaf_plot <- columnize(C_leaf[harvest,])
C_fruit_plot <- columnize(C_fruit[harvest,])
Cem_root <- c(1.43, 1.93,3.82,3.67,10.8,49,87.4, 150)
Cem_stem <- c(2.39, 1.9, 2.58, 4.77, 6.97, 9.25, 10.4, 9.04)
Cem_twig <- c(13.4, 7.04, 10.9, 11.8, 11.5, 11.9, 11.7, 7.83)
Cem_leaf <- c(42.6, 11.8, 49.2, 75.5, 85.8, 65.8, 39.3, 11.3)
Cem_fruit <- c(5.56, 6.49, 3.4, 0.54, 0.28, 0.071, 0.025, 0.0065)

df <- data.frame(Substance, N_carbon, lgKow_i_plot, C_spw, 
                 C_root_plot, C_stem_plot, C_twig_plot, C_leaf_plot, C_fruit_plot,
                 Cem_root, Cem_stem, Cem_twig, Cem_leaf, Cem_fruit)
# cleaning
df$Substance <- factor(df$Substance, levels = unique(df$Substance))

summary(df)
str(df)
View(df)

color <- c("royalblue1","sandybrown")
# Define common x-axis limits
xlim_common <- range(df$lgKow_i_plot, na.rm = TRUE)
ylim_root <- range(df$C_root_plot, df$Cem_root, na.rm = TRUE)
ylim_stem <- range(df$C_stem_plot, df$Cem_stem, na.rm = TRUE)
ylim_twig <- range(df$C_twig_plot, df$Cem_twig, na.rm = TRUE)
ylim_leaf <- range(df$C_leaf_plot, df$Cem_leaf, na.rm = TRUE)
ylim_fruit <- range(df$C_fruit_plot, df$Cem_fruit, na.rm = TRUE)

# Sort by X
ord <- order(df$lgKow_i)

# Set plotting layout: 2 rows, 3 column with top right empty
layout_matrix <- matrix(
  c(1,0,
    2,3,
    4,5),
  nrow = 3,
  byrow = TRUE
)

layout(layout_matrix,
       heights = c(1.1, 1.1, 1.1))

par(mar = c(6, 6, 2, 1),   # margins for inner plots
    oma = c(4, 2, 1, 2),   # outer margin for shared x-axis label
    mgp = c(0, 1.2, 0),    # Axis title, tick labels, axis line distances
    cex.main = 1.6,
    cex.axis = 1.8,
    las = 1
)

# 1. Root
plot(df$lgKow_i_plot, df$C_root_plot,
     pch = 16, xlim = xlim_common, ylim = ylim_root,
     xlab = "", ylab = "",
     col = color[1],
     cex = 2.5,
     main = "Root", 
     xaxt = "n")         # remove x-axis
points(df$lgKow_i_plot, 
       df$Cem_root, 
       pch = 15, 
       cex = 2.5, 
       col = color[2])
lines(df$lgKow_i_plot[ord], 
      df$C_root_plot[ord],
      lwd = 2, 
      lty = 2, 
      col = color[1])
lines(df$lgKow_i_plot[ord], 
      df$Cem_root[ord],
      lwd = 2, 
      lty = 2, 
      col = color[2])
mtext("A",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)


# 2. Stem
plot(df$lgKow_i_plot, df$C_stem_plot,
     pch = 16, xlim = xlim_common, ylim = ylim_stem,
     xlab = "", ylab = "",
     col = color[1],
     cex = 2.5,
     main = "Stem",
     xaxt = "n")         # remove x-axis
points(df$lgKow_i_plot, 
       df$Cem_stem, 
       pch = 15, 
       cex = 2.5, 
       col = color[2])
lines(df$lgKow_i_plot[ord], 
      df$C_stem_plot[ord],
      lwd = 2, 
      lty = 2, 
      col = color[1])
lines(df$lgKow_i_plot[ord], 
      df$Cem_stem[ord],
      lwd = 2, 
      lty = 2, 
      col = color[2])
mtext("B",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 3. Twig
plot(df$lgKow_i_plot, df$C_twig_plot,
     pch = 16, xlim = xlim_common, ylim = ylim_twig,
     xlab = "", ylab = "",
     col = color[1],
     cex = 2.5,
     main = "Twig",
     xaxt = "n")         # remove x-axis
points(df$lgKow_i_plot, 
       df$Cem_twig, 
       pch = 15, 
       cex = 2.5, 
       col = color[2])
lines(df$lgKow_i_plot[ord], 
      df$C_twig_plot[ord],
      lwd = 2, 
      lty = 2, 
      col = color[1])
lines(df$lgKow_i_plot[ord], 
      df$Cem_twig[ord],
      lwd = 2, 
      lty = 2, 
      col = color[2])
mtext("C",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 4. Leaf
plot(df$lgKow_i_plot, df$C_leaf_plot,
     pch = 16, xlim = xlim_common, ylim = ylim_leaf,
     xlab = "", ylab = "",
     col = color[1],
     cex = 2.5,
     main = "Leaf",
     xaxt = "n")         # remove x-axis
points(df$lgKow_i_plot, 
       df$Cem_leaf, 
       pch = 15, 
       cex = 2.5, 
       col = color[2])
lines(df$lgKow_i_plot[ord], 
      df$C_leaf_plot[ord],
      lwd = 2, 
      lty = 2, 
      col = color[1])
lines(df$lgKow_i_plot[ord], 
      df$Cem_leaf[ord],
      lwd = 2, 
      lty = 2, 
      col = color[2])
axis(side = 1, 
     at = lgKow_i_plot, labels = FALSE,
     tick = TRUE)
text(x = lgKow_i_plot,
     y = par("usr")[3] - 0.08*diff(par("usr")[3:4]),
     labels = Substance,
     srt = 45,
     adj = 1,
     xpd = TRUE,
     cex = 1.1)
text(x = lgKow_i_plot,
     y = par("usr")[3] - 0.29*diff(par("usr")[3:4]),
     labels = lgKow_i_plot,
     srt = 45,
     adj = 1,
     xpd = TRUE,
     cex = 1.1)
mtext("D",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 5. Fruit (bottom panel gets x-axis)
plot(df$lgKow_i_plot, df$C_fruit_plot,
     pch = 16, xlim = xlim_common, ylim = ylim_fruit,
     xlab = "", ylab = "",
     col = color[1],
     cex = 2.5,
     main = "Fruit",
     xaxt = "n")         # remove x-axis
points(df$lgKow_i_plot, 
       df$Cem_fruit, 
       pch = 15, 
       cex = 2.5, 
       col = color[2])
lines(df$lgKow_i_plot[ord], 
      df$C_fruit_plot[ord],
      lwd = 2, 
      lty = 2, 
      col = color[1])
lines(df$lgKow_i_plot[ord], 
      df$Cem_fruit[ord],
      lwd = 2, 
      lty = 2, 
      col = color[2])
axis(side = 1, 
     at = lgKow_i_plot, labels = FALSE,
     tick = TRUE)
text(x = lgKow_i_plot,
     y = par("usr")[3] - 0.08*diff(par("usr")[3:4]),
     labels = Substance,
     srt = 45,
     adj = 1,
     xpd = TRUE,
     cex = 1.1)
text(x = lgKow_i_plot,
     y = par("usr")[3] - 0.29*diff(par("usr")[3:4]),
     labels = lgKow_i_plot,
     srt = 45,
     adj = 1,
     xpd = TRUE,
     cex = 1.1)
mtext("E",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# Shared x-axis label
mtext("PFCA Substance / lgKow_i", side = 1, line = 1.1, cex = 1.4, outer = TRUE, font = 2)
mtext("Tissue concentration (μg/kg fresh weight)", side = 2, line = -1, cex = 1.5, las = 0, outer = TRUE)

# Add shared legend in outer margin (top center)
par(fig = c(0, 0.98, 0, 0.96), oma = c(0, 1, 1, 1), mar = c(0, 0, 0, 0), new = TRUE)
plot.new()

legend("topright",
       legend = c("Modelled results", "Experimental results"),
       inset = c(0, 0),
       pch = c(16, 15),
       lty = c(2, 2),
       lwd = 2,
       xpd = TRUE,                                                               # this allows plotting outside the figure region
       col = color,
       pt.cex = 3, 
       text.font = 2,
       cex = 2,
       x.intersp = 1,
       y.intersp = 1.2,
       text.width = 0.18,
       bty = "o")

# 6. Plotting for dynamic prediction
Day <- c(1:harvest)

# 6.1 PFBA
# Import results
PFBA <- c(rep("PFBA", harvest))
C_root_dy <- columnize(C_root[,"PFBA"])
C_stem_dy <- columnize(C_stem[,"PFBA"])
C_twig_dy <- columnize(C_twig[,"PFBA"])
C_leaf_dy <- columnize(C_leaf[,"PFBA"])
C_fruit_dy <- columnize(C_fruit[,"PFBA"])

df_dy <- data.frame(PFBA, Day,  
                 C_root_dy, C_stem_dy, C_twig_dy, C_leaf_dy, C_fruit_dy)

# cleaning
summary(df_dy)
str(df_dy)

# Define common x-axis limits
xlim_dy <- range(df_dy$Day, na.rm = TRUE)
ylim_root_dy <- range(df_dy$C_root_dy, na.rm = TRUE)
ylim_stem_dy <- range(df_dy$C_stem_dy, na.rm = TRUE)
ylim_twig_dy <- range(df_dy$C_twig_dy, na.rm = TRUE)
ylim_leaf_dy <- range(df_dy$C_leaf_dy, na.rm = TRUE)
ylim_fruit_dy <- range(df_dy$C_fruit_dy, na.rm = TRUE)

day_ticks <- seq(0,100, by = 5)

# Sort by X
ord_dy <- order(df_dy$Day)

# Set plotting layout: 2 rows, 3 column with top right empty
layout_dy <- matrix(
  c(1,0,
    2,3,
    4,5),
  nrow = 3,
  byrow = TRUE
)

layout(layout_dy,
       heights = c(1.2, 1.2, 1.2))

par(mar = c(2, 6, 2, 1),   # margins for inner plots
    oma = c(4, 2, 1, 2),   # outer margin for shared x-axis label
    mgp = c(0, 1.2, 0),    # Axis title, tick labels, axis line distances
    cex.main = 1.6,
    cex.axis = 1.8,
    las = 1
)

# 1. Root
plot(df_dy$Day, df_dy$C_root_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_root_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Root", 
     xaxt = "n")         # remove x-axis
mtext("A",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)
# 2. Stem
plot(df_dy$Day, df_dy$C_stem_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_stem_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Stem",
     xaxt = "n")         # remove x-axis
mtext("B",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 3. Twig
plot(df_dy$Day, df_dy$C_twig_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_twig_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Twig",
     xaxt = "n")         # remove x-axis
mtext("C",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 4. Leaf
plot(df_dy$Day, df_dy$C_leaf_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_leaf_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Leaf",
     xaxt = "n")
axis(side = 1,
     at = day_ticks,
     labels = day_ticks,
     cex.axis = 1.5)
mtext("D",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 5. Fruit (bottom panel gets x-axis)
plot(df_dy$Day, df_dy$C_fruit_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_fruit_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Fruit",
     xaxt = "n")         # remove x-axis
axis(side = 1, 
     at = day_ticks, 
     labels = day_ticks,
     cex.axis = 1.5)
mtext("E",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# Shared x-axis label
mtext("Day", side = 1, line = 1.5, cex = 1.4, outer = TRUE, font = 2)
mtext("Modelled PFBA concentrations (μg/kg fresh weight)", side = 2, line = -1, cex = 1.5, las = 0, outer = TRUE)

# 6.2 PFOA
# Import results
PFOA <- c(rep("PFOA", harvest))
C_root_dy <- columnize(C_root[,"PFOA"])
C_stem_dy <- columnize(C_stem[,"PFOA"])
C_twig_dy <- columnize(C_twig[,"PFOA"])
C_leaf_dy <- columnize(C_leaf[,"PFOA"])
C_fruit_dy <- columnize(C_fruit[,"PFOA"])

df_dy <- data.frame(PFOA, Day,  
                    C_root_dy, C_stem_dy, C_twig_dy, C_leaf_dy, C_fruit_dy)

# cleaning
summary(df_dy)
str(df_dy)

# Define common x-axis limits
xlim_dy <- range(df_dy$Day, na.rm = TRUE)
ylim_root_dy <- range(df_dy$C_root_dy, na.rm = TRUE)
ylim_stem_dy <- range(df_dy$C_stem_dy, na.rm = TRUE)
ylim_twig_dy <- range(df_dy$C_twig_dy, na.rm = TRUE)
ylim_leaf_dy <- range(df_dy$C_leaf_dy, na.rm = TRUE)
ylim_fruit_dy <- range(df_dy$C_fruit_dy, na.rm = TRUE)

day_ticks <- seq(0,100, by = 5)

# Sort by X
ord_dy <- order(df_dy$Day)

# Set plotting layout: 2 rows, 3 column with top right empty
layout_dy <- matrix(
  c(1,0,
    2,3,
    4,5),
  nrow = 3,
  byrow = TRUE
)

layout(layout_dy,
       heights = c(1.2, 1.2, 1.2))

par(mar = c(2, 6, 2, 1),   # margins for inner plots
    oma = c(4, 2, 1, 2),   # outer margin for shared x-axis label
    mgp = c(0, 1.2, 0),    # Axis title, tick labels, axis line distances
    cex.main = 1.6,
    cex.axis = 1.8,
    las = 1
)

# 1. Root
plot(df_dy$Day, df_dy$C_root_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_root_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Root", 
     xaxt = "n")         # remove x-axis
mtext("A",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)
# 2. Stem
plot(df_dy$Day, df_dy$C_stem_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_stem_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Stem",
     xaxt = "n")         # remove x-axis
mtext("B",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 3. Twig
plot(df_dy$Day, df_dy$C_twig_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_twig_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Twig",
     xaxt = "n")         # remove x-axis
mtext("C",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 4. Leaf
plot(df_dy$Day, df_dy$C_leaf_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_leaf_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Leaf",
     xaxt = "n")
axis(side = 1,
     at = day_ticks,
     labels = day_ticks,
     cex.axis = 1.5)
mtext("D",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 5. Fruit (bottom panel gets x-axis)
plot(df_dy$Day, df_dy$C_fruit_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_fruit_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Fruit",
     xaxt = "n")         # remove x-axis
axis(side = 1, 
     at = day_ticks, 
     labels = day_ticks,
     cex.axis = 1.5)
mtext("E",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# Shared x-axis label
mtext("Day", side = 1, line = 1.5, cex = 1.4, outer = TRUE, font = 2)
mtext("Modelled PFOA concentrations (μg/kg fresh weight)", side = 2, line = -1, cex = 1.5, las = 0, outer = TRUE)

# 6.3 PFPeA
# Import results
PFPeA <- c(rep("PFPeA", harvest))
C_root_dy <- columnize(C_root[,"PFPeA"])
C_stem_dy <- columnize(C_stem[,"PFPeA"])
C_twig_dy <- columnize(C_twig[,"PFPeA"])
C_leaf_dy <- columnize(C_leaf[,"PFPeA"])
C_fruit_dy <- columnize(C_fruit[,"PFPeA"])

df_dy <- data.frame(PFPeA, Day,  
                    C_root_dy, C_stem_dy, C_twig_dy, C_leaf_dy, C_fruit_dy)

# cleaning
summary(df_dy)
str(df_dy)

# Define common x-axis limits
xlim_dy <- range(df_dy$Day, na.rm = TRUE)
ylim_root_dy <- range(df_dy$C_root_dy, na.rm = TRUE)
ylim_stem_dy <- range(df_dy$C_stem_dy, na.rm = TRUE)
ylim_twig_dy <- range(df_dy$C_twig_dy, na.rm = TRUE)
ylim_leaf_dy <- range(df_dy$C_leaf_dy, na.rm = TRUE)
ylim_fruit_dy <- range(df_dy$C_fruit_dy, na.rm = TRUE)

day_ticks <- seq(0,100, by = 5)

# Sort by X
ord_dy <- order(df_dy$Day)

# Set plotting layout: 2 rows, 3 column with top right empty
layout_dy <- matrix(
  c(1,0,
    2,3,
    4,5),
  nrow = 3,
  byrow = TRUE
)

layout(layout_dy,
       heights = c(1.2, 1.2, 1.2))

par(mar = c(2, 6, 2, 1),   # margins for inner plots
    oma = c(4, 2, 1, 2),   # outer margin for shared x-axis label
    mgp = c(0, 1.2, 0),    # Axis title, tick labels, axis line distances
    cex.main = 1.6,
    cex.axis = 1.8,
    las = 1
)

# 1. Root
plot(df_dy$Day, df_dy$C_root_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_root_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Root", 
     xaxt = "n")         # remove x-axis
mtext("A",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)
# 2. Stem
plot(df_dy$Day, df_dy$C_stem_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_stem_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Stem",
     xaxt = "n")         # remove x-axis
mtext("B",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 3. Twig
plot(df_dy$Day, df_dy$C_twig_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_twig_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Twig",
     xaxt = "n")         # remove x-axis
mtext("C",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 4. Leaf
plot(df_dy$Day, df_dy$C_leaf_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_leaf_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Leaf",
     xaxt = "n")
axis(side = 1,
     at = day_ticks,
     labels = day_ticks,
     cex.axis = 1.5)
mtext("D",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 5. Fruit (bottom panel gets x-axis)
plot(df_dy$Day, df_dy$C_fruit_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_fruit_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Fruit",
     xaxt = "n")         # remove x-axis
axis(side = 1, 
     at = day_ticks, 
     labels = day_ticks,
     cex.axis = 1.5)
mtext("E",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# Shared x-axis label
mtext("Day", side = 1, line = 1.5, cex = 1.4, outer = TRUE, font = 2)
mtext("Modelled PFPeA concentrations (μg/kg fresh weight)", side = 2, line = -1, cex = 1.5, las = 0, outer = TRUE)

# 6.4 PFHxA
# Import results
PFHxA <- c(rep("PFHxA", harvest))
C_root_dy <- columnize(C_root[,"PFHxA"])
C_stem_dy <- columnize(C_stem[,"PFHxA"])
C_twig_dy <- columnize(C_twig[,"PFHxA"])
C_leaf_dy <- columnize(C_leaf[,"PFHxA"])
C_fruit_dy <- columnize(C_fruit[,"PFHxA"])

df_dy <- data.frame(PFHxA, Day,  
                    C_root_dy, C_stem_dy, C_twig_dy, C_leaf_dy, C_fruit_dy)

# cleaning
summary(df_dy)
str(df_dy)

# Define common x-axis limits
xlim_dy <- range(df_dy$Day, na.rm = TRUE)
ylim_root_dy <- range(df_dy$C_root_dy, na.rm = TRUE)
ylim_stem_dy <- range(df_dy$C_stem_dy, na.rm = TRUE)
ylim_twig_dy <- range(df_dy$C_twig_dy, na.rm = TRUE)
ylim_leaf_dy <- range(df_dy$C_leaf_dy, na.rm = TRUE)
ylim_fruit_dy <- range(df_dy$C_fruit_dy, na.rm = TRUE)

day_ticks <- seq(0,100, by = 5)

# Sort by X
ord_dy <- order(df_dy$Day)

# Set plotting layout: 2 rows, 3 column with top right empty
layout_dy <- matrix(
  c(1,0,
    2,3,
    4,5),
  nrow = 3,
  byrow = TRUE
)

layout(layout_dy,
       heights = c(1.2, 1.2, 1.2))

par(mar = c(2, 6, 2, 1),   # margins for inner plots
    oma = c(4, 2, 1, 2),   # outer margin for shared x-axis label
    mgp = c(0, 1.2, 0),    # Axis title, tick labels, axis line distances
    cex.main = 1.6,
    cex.axis = 1.8,
    las = 1
)

# 1. Root
plot(df_dy$Day, df_dy$C_root_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_root_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Root", 
     xaxt = "n")         # remove x-axis
mtext("A",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)
# 2. Stem
plot(df_dy$Day, df_dy$C_stem_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_stem_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Stem",
     xaxt = "n")         # remove x-axis
mtext("B",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 3. Twig
plot(df_dy$Day, df_dy$C_twig_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_twig_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Twig",
     xaxt = "n")         # remove x-axis
mtext("C",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 4. Leaf
plot(df_dy$Day, df_dy$C_leaf_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_leaf_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Leaf",
     xaxt = "n")
axis(side = 1,
     at = day_ticks,
     labels = day_ticks,
     cex.axis = 1.5)
mtext("D",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 5. Fruit (bottom panel gets x-axis)
plot(df_dy$Day, df_dy$C_fruit_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_fruit_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Fruit",
     xaxt = "n")         # remove x-axis
axis(side = 1, 
     at = day_ticks, 
     labels = day_ticks,
     cex.axis = 1.5)
mtext("E",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# Shared x-axis label
mtext("Day", side = 1, line = 1.5, cex = 1.4, outer = TRUE, font = 2)
mtext("Modelled PFHxA concentrations (μg/kg fresh weight)", side = 2, line = -1, cex = 1.5, las = 0, outer = TRUE)

# 6.5 PFHpA
# Import results
PFHpA <- c(rep("PFHpA", harvest))
C_root_dy <- columnize(C_root[,"PFHpA"])
C_stem_dy <- columnize(C_stem[,"PFHpA"])
C_twig_dy <- columnize(C_twig[,"PFHpA"])
C_leaf_dy <- columnize(C_leaf[,"PFHpA"])
C_fruit_dy <- columnize(C_fruit[,"PFHpA"])

df_dy <- data.frame(PFHpA, Day,  
                    C_root_dy, C_stem_dy, C_twig_dy, C_leaf_dy, C_fruit_dy)

# cleaning
summary(df_dy)
str(df_dy)

# Define common x-axis limits
xlim_dy <- range(df_dy$Day, na.rm = TRUE)
ylim_root_dy <- range(df_dy$C_root_dy, na.rm = TRUE)
ylim_stem_dy <- range(df_dy$C_stem_dy, na.rm = TRUE)
ylim_twig_dy <- range(df_dy$C_twig_dy, na.rm = TRUE)
ylim_leaf_dy <- range(df_dy$C_leaf_dy, na.rm = TRUE)
ylim_fruit_dy <- range(df_dy$C_fruit_dy, na.rm = TRUE)

day_ticks <- seq(0,100, by = 5)

# Sort by X
ord_dy <- order(df_dy$Day)

# Set plotting layout: 2 rows, 3 column with top right empty
layout_dy <- matrix(
  c(1,0,
    2,3,
    4,5),
  nrow = 3,
  byrow = TRUE
)

layout(layout_dy,
       heights = c(1.2, 1.2, 1.2))

par(mar = c(2, 6, 2, 1),   # margins for inner plots
    oma = c(4, 2, 1, 2),   # outer margin for shared x-axis label
    mgp = c(0, 1.2, 0),    # Axis title, tick labels, axis line distances
    cex.main = 1.6,
    cex.axis = 1.8,
    las = 1
)

# 1. Root
plot(df_dy$Day, df_dy$C_root_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_root_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Root", 
     xaxt = "n")         # remove x-axis
mtext("A",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)
# 2. Stem
plot(df_dy$Day, df_dy$C_stem_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_stem_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Stem",
     xaxt = "n")         # remove x-axis
mtext("B",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 3. Twig
plot(df_dy$Day, df_dy$C_twig_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_twig_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Twig",
     xaxt = "n")         # remove x-axis
mtext("C",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 4. Leaf
plot(df_dy$Day, df_dy$C_leaf_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_leaf_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Leaf",
     xaxt = "n")
axis(side = 1,
     at = day_ticks,
     labels = day_ticks,
     cex.axis = 1.5)
mtext("D",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 5. Fruit (bottom panel gets x-axis)
plot(df_dy$Day, df_dy$C_fruit_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_fruit_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Fruit",
     xaxt = "n")         # remove x-axis
axis(side = 1, 
     at = day_ticks, 
     labels = day_ticks,
     cex.axis = 1.5)
mtext("E",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# Shared x-axis label
mtext("Day", side = 1, line = 1.5, cex = 1.4, outer = TRUE, font = 2)
mtext("Modelled PFHpA concentrations (μg/kg fresh weight)", side = 2, line = -1, cex = 1.5, las = 0, outer = TRUE)

# 6.6 PFNA
# Import results
PFNA <- c(rep("PFNA", harvest))
C_root_dy <- columnize(C_root[,"PFNA"])
C_stem_dy <- columnize(C_stem[,"PFNA"])
C_twig_dy <- columnize(C_twig[,"PFNA"])
C_leaf_dy <- columnize(C_leaf[,"PFNA"])
C_fruit_dy <- columnize(C_fruit[,"PFNA"])

df_dy <- data.frame(PFNA, Day,  
                    C_root_dy, C_stem_dy, C_twig_dy, C_leaf_dy, C_fruit_dy)

# cleaning
summary(df_dy)
str(df_dy)

# Define common x-axis limits
xlim_dy <- range(df_dy$Day, na.rm = TRUE)
ylim_root_dy <- range(df_dy$C_root_dy, na.rm = TRUE)
ylim_stem_dy <- range(df_dy$C_stem_dy, na.rm = TRUE)
ylim_twig_dy <- range(df_dy$C_twig_dy, na.rm = TRUE)
ylim_leaf_dy <- range(df_dy$C_leaf_dy, na.rm = TRUE)
ylim_fruit_dy <- range(df_dy$C_fruit_dy, na.rm = TRUE)

day_ticks <- seq(0,100, by = 5)

# Sort by X
ord_dy <- order(df_dy$Day)

# Set plotting layout: 2 rows, 3 column with top right empty
layout_dy <- matrix(
  c(1,0,
    2,3,
    4,5),
  nrow = 3,
  byrow = TRUE
)

layout(layout_dy,
       heights = c(1.2, 1.2, 1.2))

par(mar = c(2, 6, 2, 1),   # margins for inner plots
    oma = c(4, 2, 1, 2),   # outer margin for shared x-axis label
    mgp = c(0, 1.2, 0),    # Axis title, tick labels, axis line distances
    cex.main = 1.6,
    cex.axis = 1.8,
    las = 1
)

# 1. Root
plot(df_dy$Day, df_dy$C_root_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_root_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Root", 
     xaxt = "n")         # remove x-axis
mtext("A",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)
# 2. Stem
plot(df_dy$Day, df_dy$C_stem_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_stem_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Stem",
     xaxt = "n")         # remove x-axis
mtext("B",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 3. Twig
plot(df_dy$Day, df_dy$C_twig_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_twig_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Twig",
     xaxt = "n")         # remove x-axis
mtext("C",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 4. Leaf
plot(df_dy$Day, df_dy$C_leaf_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_leaf_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Leaf",
     xaxt = "n")
axis(side = 1,
     at = day_ticks,
     labels = day_ticks,
     cex.axis = 1.5)
mtext("D",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 5. Fruit (bottom panel gets x-axis)
plot(df_dy$Day, df_dy$C_fruit_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_fruit_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Fruit",
     xaxt = "n")         # remove x-axis
axis(side = 1, 
     at = day_ticks, 
     labels = day_ticks,
     cex.axis = 1.5)
mtext("E",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# Shared x-axis label
mtext("Day", side = 1, line = 1.5, cex = 1.4, outer = TRUE, font = 2)
mtext("Modelled PFNA concentrations (μg/kg fresh weight)", side = 2, line = -1, cex = 1.5, las = 0, outer = TRUE)

# 6.7 PFDA
# Import results
PFDA <- c(rep("PFDA", harvest))
C_root_dy <- columnize(C_root[,"PFDA"])
C_stem_dy <- columnize(C_stem[,"PFDA"])
C_twig_dy <- columnize(C_twig[,"PFDA"])
C_leaf_dy <- columnize(C_leaf[,"PFDA"])
C_fruit_dy <- columnize(C_fruit[,"PFDA"])

df_dy <- data.frame(PFDA, Day,  
                    C_root_dy, C_stem_dy, C_twig_dy, C_leaf_dy, C_fruit_dy)

# cleaning
summary(df_dy)
str(df_dy)

# Define common x-axis limits
xlim_dy <- range(df_dy$Day, na.rm = TRUE)
ylim_root_dy <- range(df_dy$C_root_dy, na.rm = TRUE)
ylim_stem_dy <- range(df_dy$C_stem_dy, na.rm = TRUE)
ylim_twig_dy <- range(df_dy$C_twig_dy, na.rm = TRUE)
ylim_leaf_dy <- range(df_dy$C_leaf_dy, na.rm = TRUE)
ylim_fruit_dy <- range(df_dy$C_fruit_dy, na.rm = TRUE)

day_ticks <- seq(0,100, by = 5)

# Sort by X
ord_dy <- order(df_dy$Day)

# Set plotting layout: 2 rows, 3 column with top right empty
layout_dy <- matrix(
  c(1,0,
    2,3,
    4,5),
  nrow = 3,
  byrow = TRUE
)

layout(layout_dy,
       heights = c(1.2, 1.2, 1.2))

par(mar = c(2, 6, 2, 1),   # margins for inner plots
    oma = c(4, 2, 1, 2),   # outer margin for shared x-axis label
    mgp = c(0, 1.2, 0),    # Axis title, tick labels, axis line distances
    cex.main = 1.6,
    cex.axis = 1.8,
    las = 1
)

# 1. Root
plot(df_dy$Day, df_dy$C_root_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_root_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Root", 
     xaxt = "n")         # remove x-axis
mtext("A",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)
# 2. Stem
plot(df_dy$Day, df_dy$C_stem_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_stem_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Stem",
     xaxt = "n")         # remove x-axis
mtext("B",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 3. Twig
plot(df_dy$Day, df_dy$C_twig_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_twig_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Twig",
     xaxt = "n")         # remove x-axis
mtext("C",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 4. Leaf
plot(df_dy$Day, df_dy$C_leaf_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_leaf_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Leaf",
     xaxt = "n")
axis(side = 1,
     at = day_ticks,
     labels = day_ticks,
     cex.axis = 1.5)
mtext("D",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 5. Fruit (bottom panel gets x-axis)
plot(df_dy$Day, df_dy$C_fruit_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_fruit_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Fruit",
     xaxt = "n")         # remove x-axis
axis(side = 1, 
     at = day_ticks, 
     labels = day_ticks,
     cex.axis = 1.5)
mtext("E",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# Shared x-axis label
mtext("Day", side = 1, line = 1.5, cex = 1.4, outer = TRUE, font = 2)
mtext("Modelled PFDA concentrations (μg/kg fresh weight)", side = 2, line = -1, cex = 1.5, las = 0, outer = TRUE)

# 6.8 PFUnA
# Import results
PFUnA <- c(rep("PFUnA", harvest))
C_root_dy <- columnize(C_root[,"PFUnA"])
C_stem_dy <- columnize(C_stem[,"PFUnA"])
C_twig_dy <- columnize(C_twig[,"PFUnA"])
C_leaf_dy <- columnize(C_leaf[,"PFUnA"])
C_fruit_dy <- columnize(C_fruit[,"PFUnA"])

df_dy <- data.frame(PFUnA, Day,  
                    C_root_dy, C_stem_dy, C_twig_dy, C_leaf_dy, C_fruit_dy)

# cleaning
summary(df_dy)
str(df_dy)

# Define common x-axis limits
xlim_dy <- range(df_dy$Day, na.rm = TRUE)
ylim_root_dy <- range(df_dy$C_root_dy, na.rm = TRUE)
ylim_stem_dy <- range(df_dy$C_stem_dy, na.rm = TRUE)
ylim_twig_dy <- range(df_dy$C_twig_dy, na.rm = TRUE)
ylim_leaf_dy <- range(df_dy$C_leaf_dy, na.rm = TRUE)
ylim_fruit_dy <- range(df_dy$C_fruit_dy, na.rm = TRUE)

day_ticks <- seq(0,100, by = 5)

# Sort by X
ord_dy <- order(df_dy$Day)

# Set plotting layout: 2 rows, 3 column with top right empty
layout_dy <- matrix(
  c(1,0,
    2,3,
    4,5),
  nrow = 3,
  byrow = TRUE
)

layout(layout_dy,
       heights = c(1.2, 1.2, 1.2))

par(mar = c(2, 6, 2, 1),   # margins for inner plots
    oma = c(4, 2, 1, 2),   # outer margin for shared x-axis label
    mgp = c(0, 1.2, 0),    # Axis title, tick labels, axis line distances
    cex.main = 1.6,
    cex.axis = 1.8,
    las = 1
)

# 1. Root
plot(df_dy$Day, df_dy$C_root_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_root_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Root", 
     xaxt = "n")         # remove x-axis
mtext("A",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)
# 2. Stem
plot(df_dy$Day, df_dy$C_stem_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_stem_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Stem",
     xaxt = "n")         # remove x-axis
mtext("B",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 3. Twig
plot(df_dy$Day, df_dy$C_twig_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_twig_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Twig",
     xaxt = "n")         # remove x-axis
mtext("C",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 4. Leaf
plot(df_dy$Day, df_dy$C_leaf_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_leaf_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Leaf",
     xaxt = "n")
axis(side = 1,
     at = day_ticks,
     labels = day_ticks,
     cex.axis = 1.5)
mtext("D",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# 5. Fruit (bottom panel gets x-axis)
plot(df_dy$Day, df_dy$C_fruit_dy,
     pch = 16, xlim = xlim_dy, ylim = ylim_fruit_dy,
     xlab = "", ylab = "",
     col = color[1],
     cex = 0.8,
     main = "Fruit",
     xaxt = "n")         # remove x-axis
axis(side = 1, 
     at = day_ticks, 
     labels = day_ticks,
     cex.axis = 1.5)
mtext("E",
      side = 3,
      adj = 0.03,
      line = -2.5,
      font = 2,
      cex = 1.2)

# Shared x-axis label
mtext("Day", side = 1, line = 1.5, cex = 1.4, outer = TRUE, font = 2)
mtext("Modelled PFUnA concentrations (μg/kg fresh weight)", side = 2, line = -1, cex = 1.5, las = 0, outer = TRUE)