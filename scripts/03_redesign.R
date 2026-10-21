# 03_redesign.R : Q3 scatter + weighted band means
source("scripts/00_helpers.R")
library(svglite)
set.seed(1)

bands <- earners %>% group_by(band, band_mid) %>%
  summarise(n = n(), wmean = wmean(earn_annual, hhweight), .groups = "drop") %>%
  mutate(thin = n < 30) %>% arrange(band_mid)

write_csv(bands %>% mutate(wmean = round(wmean)), "figures/band_table_R.csv")
print(bands, n = 10)

top <- bands %>% filter(wmean == max(wmean))

p <- ggplot() +
  geom_jitter(data = earners, aes(age, earn_annual), width = 0.4, height = 0,
              alpha = 0.25, size = 1, colour = "grey40") +
  geom_line(data = bands, aes(band_mid, wmean), colour = "firebrick", linewidth = 0.8) +
  geom_point(data = bands, aes(band_mid, wmean, shape = thin), size = 3.5,
             colour = "firebrick", fill = "white", stroke = 1.2) +
  scale_shape_manual(values = c(`FALSE` = 16, `TRUE` = 21), guide = "none") +
  annotate("label", x = top$band_mid, y = top$wmean, vjust = -1,
           label = paste0("Highest: ages ", top$band, "\nRs ", format(round(top$wmean), big.mark = ","))) +
  scale_y_log10(limits = c(1e4, 1e7), breaks = 10^(4:7), labels = rs_labels(10^(4:7))) +
  scale_x_continuous(breaks = seq(15, 65, 5)) +
  coord_cartesian(xlim = c(14.5, 64.5)) +
  labs(title = paste0("Average earnings peak at ages ", top$band, " in urban Balochistan"),
       x = "Age (years)", y = "Annual earnings (log scale)",
       caption = paste0("Source: PSLM 2019-20. Sample: earners aged 15-64, Balochistan urban. ",
                        "Weighted by hhweight (band means). Hollow markers = bands with fewer than 30 observations.")) +
  theme_minimal()
ggsave("figures/redesign.svg", p, width = 8, height = 5.5)
