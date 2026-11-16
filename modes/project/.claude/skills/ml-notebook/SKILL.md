---
name: ml-notebook
description: Scaffold a reproducible machine-learning notebook with standard sections (data, EDA, preprocessing, modeling, evaluation). Use when starting or structuring an ML notebook.
---

# ML notebook

Create a reproducible notebook for an ML task.

## Environment
- Use uv for the environment and dependencies, never bare pip.
- Set a fixed random seed and record library versions.

## Structure (markdown headers, in English)
1. Problem and dataset: what is predicted, where the data comes from.
2. Data load and sanity checks: shape, dtypes, missing values, class balance.
3. EDA: a few focused figures, each with a one-line takeaway.
4. Preprocessing: encoding, scaling, split. Fit transforms on train only.
5. Modeling: baseline first, then the main model. One change at a time.
6. Evaluation: the metric that fits the task, on a held-out set.
7. Conclusions: what worked, what to try next.

## Rules
- Chart titles, axis labels and legends in English; one consistent style.
- Never invent or estimate values; label units and sources.
- Verify by running top to bottom before declaring it done.
- Save figures as files; do not paste large tables into chat.
