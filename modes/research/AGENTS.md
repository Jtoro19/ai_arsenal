# Mode: research

Work for the GAIA research seedbed (Universidad Nacional de Colombia, Manizales),
cybersecurity subarea. Two kinds of work live here:
1. The AI-powered intrusion-detection project: a label-by-construction, flow-level
   NIDS dataset built in an isolated GNS3 Cyber Range, and the ML studies on it.
2. Teaching material to onboard new seedbed members in cybersecurity.

## The IDS project: non-negotiable methodology

Respect these; they are the whole point of the dataset.

- Three data levels, never confused: raw PCAP (evidence, one row per packet),
  ground-truth catalog (one row per capture slot, provenance), and per-capture
  flow CSVs (trainable, 82 columns: 6 identifiers + 76 features, no label column).
- Label by construction: one capture equals one condition and one class; the file
  name (run_id) is the label. Never infer labels by time window.
- Split by capture run (the run_id in the file name), never by random row. Random
  splits put near-identical flows on both sides and inflate scores.
- Imbalance is handled at training (class weights or focal loss), never by
  manipulating the capture.
- Metrics are imbalance-robust: F1-macro, PR-AUC, MCC, per-class recall and the
  false-alarm rate. Accuracy is never a main metric.
- Leakage-aware by design: drop identifiers before training (IPs, ports,
  timestamps, Flow ID). Watch latent leakage: source port 8888 and the
  one-directional lab flows (tot_bwd_pkts = 0) mark lab rows, so a model can learn
  the source instead of the attack. Fit every transform on train rows only.
- Report honestly: separate in-capture scores from generalization. A high score on
  this data usually describes capture separability, not attack detection. Run the
  cross-source and cross-condition tests and state what each one does and does not
  prove.
- Reproducibility: keep each study in its own numbered stage folder with its own
  scripts, results and report. Re-extract from the retained PCAPs rather than
  recapturing. Read numbers from result files; do not recompute or invent them.

## Known open items (do not re-claim as solved)

- Lab flows are one-directional because the extractor does not decode 802.1Q tags;
  a clean bidirectional re-extraction (tags stripped) is still open.
- The firewall A/B effect has not been isolated with a clean design (the
  cross-condition test mixes the firewall with the capture session).

## Teaching material

- Build didactic material for new members: clear, example-driven, section by section.
- Favor hands-on labs over theory dumps; tie concepts to the project where it helps.
- Keep it accurate and cite sources; do not oversimplify to the point of error.

## Rules

- Follow the global rules (English in files, no em dashes, verify before done).
- Persist decisions and root causes to Engram (What, Why, Where, Learned).
