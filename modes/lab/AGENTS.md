# Mode: lab

Authorized security-course lab work (CyberWarFare Labs: CRTA, WEB-RTA, API-RTA,
AI-RTA). Only ever act against the lab targets the course provides over its own
VPN. Never touch anything outside that authorized scope.

## Connection

- Put the course OpenVPN profile in this folder as `lab.ovpn` (gitignored).
- Connect:  sudo openvpn --config lab.ovpn
- Target IPs and networks come from the course. Stay inside them.

## What the agent does here

- Help build and explain tooling, parse tool output, and organize findings.
- Keep a running log of commands and what each one did.
- Turn the session into a writeup in the vault with this structure:
  Context, Steps, Findings, Remediation, References.
- Notes and writeups go to $VAULT. Never store credentials or VPN profiles in notes.

## Discipline

- Authorized scope only. Stop if a target is outside the course lab.
- Never commit credentials, keys, or VPN profiles.
