# 00_helpers.R : data tayyar karna + weighted functions (har script isko source karta hai)
library(tidyverse)

# Variant 7 = Balochistan urban  -> prov_code 4, urban_rural 2
PROV <- 4
AREA <- 2

person <- read_csv("data/pslm_person_subset.csv", show_col_types = FALSE)
hh     <- read_csv("data/pslm_hh_subset.csv", show_col_types = FALSE)

# Household file se weight, province, area uthao
hh_small <- hh %>% select(hhid, hhweight, prov_code, urban_rural) %>% distinct(hhid, .keep_all = TRUE)

earners <- person %>%
  left_join(hh_small, by = "hhid") %>%
  filter(prov_code == PROV, urban_rural == AREA,
         age >= 15, age <= 64, earn_annual > 0) %>%
  mutate(band_no  = floor((age - 15) / 5),
         band_lo  = 15 + 5 * band_no,
         band     = paste0(band_lo, "-", band_lo + 4),
         band_mid = band_lo + 2)

# Weighted mean: sum(w*x)/sum(w)
wmean <- function(x, w) sum(w * x) / sum(w)

# Weighted quantile (assignment ki exact definition):
# x sort karo, cumulative weight share nikalo, pehla x jahan share >= p
wquant <- function(x, w, p) {
  o  <- order(x)
  x  <- x[o]; w <- w[o]
  cs <- cumsum(w) / sum(w)
  x[which(cs >= p - 1e-12)[1]]
}

rs_labels <- function(x) paste0("Rs ", format(x, big.mark = ",", scientific = FALSE, trim = TRUE))

dir.create("figures", showWarnings = FALSE)
