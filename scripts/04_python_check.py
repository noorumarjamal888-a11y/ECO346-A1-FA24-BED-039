# 04_python_check.py : Q5 same band table + figure in Python
import numpy as np, pandas as pd, matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.ticker import FixedLocator, FixedFormatter

PROV, AREA = 4, 2
person = pd.read_csv("data/pslm_person_subset.csv")
hh = pd.read_csv("data/pslm_hh_subset.csv")[["hhid", "hhweight", "prov_code", "urban_rural"]].drop_duplicates("hhid")

d = person.merge(hh, on="hhid", how="left")
d = d[(d.prov_code == PROV) & (d.urban_rural == AREA) &
      d.age.between(15, 64) & (d.earn_annual > 0)].copy()
d["band_lo"] = 15 + 5 * ((d.age - 15) // 5)
d["band"] = d.band_lo.astype(int).astype(str) + "-" + (d.band_lo + 4).astype(int).astype(str)
d["band_mid"] = d.band_lo + 2

g = d.groupby(["band", "band_mid"])
bands = g.apply(lambda s: pd.Series({
    "n": len(s),
    "wmean": (s.hhweight * s.earn_annual).sum() / s.hhweight.sum()})).reset_index()
bands = bands.sort_values("band_mid")
bands["thin"] = bands.n < 30
bands["wmean_rounded"] = bands.wmean.round().astype(int)   # nearest rupee
print(bands)
bands.to_csv("figures/band_table_python.csv", index=False)

rng = np.random.default_rng(1)
fig, ax = plt.subplots(figsize=(8, 5.5))
ax.scatter(d.age + rng.uniform(-0.4, 0.4, len(d)), d.earn_annual, s=6, alpha=0.25, color="grey")
ax.plot(bands.band_mid, bands.wmean, color="firebrick", lw=1.5)
for _, r in bands.iterrows():
    ax.scatter(r.band_mid, r.wmean, s=70, color="firebrick",
               facecolor="white" if r.thin else "firebrick", zorder=3, linewidths=1.5)
top = bands.loc[bands.wmean.idxmax()]
ax.annotate(f"Highest: ages {top.band}\nRs {int(round(top.wmean)):,}", (top.band_mid, top.wmean),
            xytext=(0, 25), textcoords="offset points", ha="center",
            bbox=dict(boxstyle="round", fc="white"))
ax.set_yscale("log"); ax.set_ylim(1e4, 1e7); ax.set_xlim(14.5, 64.5)
ax.yaxis.set_major_locator(FixedLocator([1e4, 1e5, 1e6, 1e7]))
ax.yaxis.set_major_formatter(FixedFormatter(["Rs 10,000", "Rs 100,000", "Rs 1,000,000", "Rs 10,000,000"]))
ax.minorticks_off()
ax.set_xlabel("Age (years)"); ax.set_ylabel("Annual earnings (log scale)")
ax.set_title(f"Average earnings peak at ages {top.band} in urban Balochistan")
fig.text(0.01, 0.01, "Source: PSLM 2019-20. Sample: earners 15-64, Balochistan urban. Weighted by hhweight. "
         "Hollow markers = fewer than 30 obs.", fontsize=7)
fig.tight_layout(rect=(0, 0.03, 1, 1))
fig.savefig("figures/redesign_python.svg")
