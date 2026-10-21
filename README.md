# ECO346 Assignment 1: Earnings in urban Balochistan

**Name:** <MAHNOOR JAMAL>
**Registration number:** <FA24-BED-039>
**Variant:** 7 (last two digits 39 = 4 x 8 + 7), so **Balochistan urban** (prov_code 4, urban_rural 2).

Data: PSLM 2019-20 person file merged with the household file by `hhid`. Sample: earners aged 15-64 with `earn_annual` > 0. All statistics are weighted by `hhweight`.

## How to reproduce
Run from the repository folder, in this order:
1. `scripts/01_default.R` (default figure; it sources `00_helpers.R`)
2. `scripts/02_histogram.R`
3. `scripts/03_redesign.R`
4. `python scripts/04_python_check.py`

## Figure 1: distribution of earnings (Q2)
![Histogram](figures/histogram.svg)

| Statistic | Value |
|---|---|
| Earners | 486 |
| Weighted median | Rs 250,000 |
| Unweighted median | Rs 264,000 |
| Weighted 10th percentile | Rs 96,000 |
| Weighted 90th percentile | Rs 540,000 |
| 90th / 10th ratio | 5.62 |
| Excluded (outside Rs 10,000 to Rs 10,000,000) | 0 |

Earnings are right-skewed: most earners lie between about Rs 96,000 and Rs 540,000, but a thin tail reaches Rs 3 million. The top tenth earn at least 5.62 times the bottom tenth. The weighted median (Rs 250,000) is below the unweighted median (Rs 264,000) because the weights give more population share to lower-earning households, so the raw sample slightly overstates what a typical urban Balochistan earner makes.

## Figure 2: earnings and age (Q3)
![Redesign](figures/redesign.svg)

| Age band | Earners | Weighted mean earnings (Rs) |
|---|---|---|
| 15-19 | 22 (thin) | 113,382 |
| 20-24 | 56 | 220,435 |
| 25-29 | 69 | 307,994 |
| 30-34 | 62 | 316,659 |
| 35-39 | 80 | 302,071 |
| 40-44 | 60 | 316,147 |
| 45-49 | 47 | 372,723 |
| 50-54 | 55 | 399,250 |
| 55-59 | 19 (thin) | 350,772 |
| 60-64 | 16 (thin) | 476,422 |

Weighted mean of 25-29: Rs 307,994. Weighted mean of 45-49: Rs 372,723. Highest band: 60-64 (Rs 476,422, a thin band).

Average earnings rise from Rs 113,382 at ages 15-19 to about Rs 308,000 at 25-29, stay roughly flat into the early forties, then climb to Rs 372,723 at 45-49 and Rs 399,250 at 50-54. The highest band, 60-64 (Rs 476,422), has only 16 earners, so it is unreliable. This fits experience raising earnings. It cannot tell us how one person's earnings change as they age: this is a single cross-section, so age is mixed with birth-cohort differences and with who is still working when older.

## The makeover (Q4)
Default (R defaults only): ![Default](figures/default.svg)

I made four changes. First, a log vertical axis labelled in rupees: on the linear default a few large values squash most points at the bottom, while the log scale shows proportional differences. Second, jitter and transparency fix overplotting: ages are whole numbers, so default points stack in columns that hide density. Third, weighted band means joined by a line show the conditional mean, read by position on a common scale, the most accurate channel. Fourth, a finding title, direct labels and less clutter raise the data-ink share. The default shows the absolute size of the top tail: the Rs 3 million earner stands far above everyone, which the log scale compresses.

## Second language: Python (Q5)
![Python figure](figures/redesign_python.svg)

25-29 band mean: R Rs 307,994, Python Rs 307,994.

Matplotlib's log axis defaults to labels like 10^4 with minor ticks, and ggplot2 prints 1e+04. I set the tick labels manually to Rs 10,000 to Rs 10,000,000 and turned minor ticks off. I also matched the 14.5 to 64.5 age range and used the same band rules, so both band tables agree to the rupee. Jittered points differ slightly because the random numbers differ.
