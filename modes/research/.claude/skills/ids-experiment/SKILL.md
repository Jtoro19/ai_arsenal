---
name: ids-experiment
description: Scaffold a downstream study on the GAIA IDS dataset following the project's locked methodology (data levels, split by run, imbalance-robust metrics, leakage checks, honest reporting). Use when starting a new analysis or model on the flow CSVs or merged datasets.
---

# IDS experiment

Set up a reproducible study on the IDS dataset.

## Folder
- One numbered stage folder for the study, with subfolders: src/, results/, figures/, report/.
- Read inputs from the per-capture flow CSVs (they carry run_id in the file name) or
  the merged datasets; never recapture.

## Pipeline (fit on train only)
1. Load and sanity-check: shape, dtypes, NaN/Inf, class counts.
2. Drop identifiers: IPs, ports, timestamps, Flow ID. Note latent leakage (port 8888,
   one-directional lab flows).
3. Split by capture run, not by random row.
4. Preprocess inside a pipeline fitted on train rows only.
5. Train: handle imbalance with class weights or focal loss.
6. Evaluate with F1-macro, PR-AUC, MCC, per-class recall and false-alarm rate.
7. Run a source probe and, where possible, a cross-source or cross-condition test.

## Reporting
- State clearly whether a score reflects in-capture separability or generalization.
- Save metrics, figures and the fitted model as files. Read numbers from files; never invent.
- Chart titles, axis labels and legends in English; one consistent style.
