# 02_histogram.R : Q2 weighted histogram (log10 scale, density)
source("scripts/00_helpers.R")
library(svglite)

n_earners <- nrow(earners)
med_w   <- wquant(earners$earn_annual, earners$hhweight, 0.5)
med_u   <- median(earners$earn_annual)
p10     <- wquant(earners$earn_annual, earners$hhweight, 0.1)
p90     <- wquant(earners$earn_annual, earners$hhweight, 0.9)
ratio   <- round(p90 / p10, 2)

earners <- earners %>% mutate(lx = log10(earn_annual))
inside  <- earners %>% filter(lx >= 4, lx <= 7)
n_excl  <- n_earners - nrow(inside)

# Har bin (0.1 wide) ka weight share / 0.1 = density per log10 unit
bins <- inside %>%
  mutate(b = pmin(floor((lx - 4) / 0.1 + 1e-9), 29)) %>%
  group_by(b) %>% summarise(w = sum(hhweight), .groups = "drop") %>%
  mutate(dens = w / sum(w) / 0.1, x = 4 + 0.1 * b + 0.05)

p <- ggplot(bins, aes(x, dens)) +
  geom_col(width = 0.1, fill = "grey60", colour = "white") +
  geom_vline(xintercept = log10(med_w), linetype = "dashed") +
  geom_vline(xintercept = log10(p90),  linetype = "dashed") +
  annotate("text", x = log10(med_w), y = max(bins$dens), hjust = 1.05, vjust = 1,
           label = paste0("Median Rs ", format(round(med_w), big.mark = ","))) +
  annotate("text", x = log10(p90), y = max(bins$dens), hjust = -0.05, vjust = 1,
           label = paste0("90th pct Rs ", format(round(p90), big.mark = ","))) +
  scale_x_continuous(breaks = 4:7, labels = rs_labels(10^(4:7)), limits = c(4, 7)) +
  labs(title = paste0("The top 10% of earners make ", ratio, " times the bottom 10%"),
       x = "Annual earnings (log scale)", y = "Density per log10 unit",
       caption = paste0("Source: PSLM 2019-20. Sample: earners aged 15-64, Balochistan urban. ",
                        "Weighted by hhweight. ", n_excl, " earners outside Rs 10,000-10,000,000 excluded.")) +
  theme_minimal()
ggsave("figures/histogram.svg", p, width = 8, height = 5)

cat("Earners:", n_earners, "\nWeighted median:", med_w, "\nUnweighted median:", med_u,
    "\nP10:", p10, "\nP90:", p90, "\nRatio:", ratio, "\nExcluded:", n_excl, "\n")
