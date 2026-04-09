# Project title: PFAS modeling plant uptake
# Project owner: Weixin Huang
# Creation date: 20241009
# Updated date: 20260121
# Update content: SA (t stays as 96 days)

# Summary of PFAS plant uptake studies by 2020: https://doi.org/10.1007/s40726-020-00168-y

# Manual for section 1: 
# [Hydroponic "training" context] 
# Plant is tomato, total growth period is 96 days with 30 days of fruiting, assuming fruiting starts from day 66, temperature is 25 degrees. 
# [Hydroponic "verification" context] 
# Plant is tomato, total growth period is 14 days with 30 days of fruiting, assuming fruiting starts from day 52, temperature is 25 degrees. 
# [Soil context]
# Plant is also tomato, 

# Scripts:
# Package loading
library(readxl)
library(ggplot2)
library(tidyr)
library(patchwork)
library(dplyr)

#1. Import results
df_SA <- read_excel("Sensitivity analysis.xlsx", sheet = "Data summary")
#df_C_p <- read_excel("Sensitivity analysis.xlsx", sheet = "C_p")
#df_P_apo <- read_excel("Sensitivity analysis.xlsx", sheet = "P_apo")
#df_PQ_apo <- read_excel("Sensitivity analysis.xlsx", sheet = "PQ_apo")
#df_k_fruit <- read_excel("Sensitivity analysis.xlsx", sheet = "k_fruit")
#df_kQ_leaf <- read_excel("Sensitivity analysis.xlsx", sheet = "kQ_leaf")
#df_t <- read_excel("Sensitivity analysis.xlsx", sheet = "t")
#df_t_fruiting <- read_excel("Sensitivity analysis.xlsx", sheet = "t_fruiting")

summary(df_SA)

#2. Cleaning
df_SA$Parameters <- as.factor(df_SA$Parameters)
summary(df_SA)

#3. Parameters 
color_SA <- c("steelblue4",
              "lightsalmon4","darkgoldenrod2", "firebrick3", "mediumpurple", 
              "darkgreen","darkolivegreen3")
pch_SA <- c(1:7)

variation <- c(0.5, -0.25, 0, 0.25, 0.5)
variation_label <- c("-50%", "-25%", "0%", "25%", "50%")
parameters <- c("C_p", "P_apo", "PQ_apo", "k_fruit", "kQ_leaf", "t", "t_fruiting")

#4. Plotting

# All in one
ggplot(df_SA,
       aes(x = `Variation (%)`,
           y = `Variation in predicted concentration in fruits (%)`,
           color = Parameters,
           group = Parameters)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_hline(yintercept = 100, linetype = "dashed") +
  scale_x_continuous(
    breaks = c(-50, -25, 0, 25, 50),
    labels = c("-50%", "-25%", "0%", "25%", "50%")
  ) +
  labs(
    x = "Parameter variation",
    y = "Relative change in PFOA concentration in fruits (%)",
    color = "Parameter"
  ) +
  theme_bw()


# multiple sub-plots
ggplot(df_SA,
       aes(x = `Variation (%)`,
           y = `Variation in predicted concentration in fruits (%)`)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  facet_wrap(~ Parameters, scales = "free_y") +
  geom_hline(yintercept = 100, linetype = "dashed", color = "grey40") +
  scale_x_continuous(
    breaks = c(-50, -25, 0, 25, 50),
    labels = c("-50%", "-25%", "0%", "25%", "50%")
  ) +
  labs(
    x = "Parameter variation",
    y = "Relative change in PFOA concentration in fruits (%)"
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    strip.text = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )
