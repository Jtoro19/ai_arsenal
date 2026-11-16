---
name: llm-redteam
description: Set up a promptfoo red-team suite against a local Ollama model (prompt injection, jailbreak, leakage, RAG poisoning). Use when designing or running LLM security tests on your own local target.
---

# LLM red-team suite

Build a reproducible promptfoo suite against a LOCAL Ollama target.

## Target
- Local, authorized models only. Point promptfoo at the OpenAI-compatible endpoint
  (OPENAI_BASE_URL, set by ai-sec mode). Start the model with: ollama serve &
- Pull the target model first with: ollama pull <model>

## Files to produce
- promptfooconfig.yaml: providers (the local model), prompts, tests, assertions.
- prompts/: one file per probe (injection, jailbreak, leakage, RAG poisoning).
- tests.yaml: expected behavior and pass/fail assertions per probe.

## Method
1. Define the system/app prompt under test and the behavior to detect.
2. Write probes that attempt it; keep each isolated and labeled.
3. Add assertions (refusal expected, no secret leakage, output schema holds).
4. Run promptfoo eval, save the results, summarize what passed and failed.

## Rules
- Local and offline only; never send payloads to third-party services.
- Payloads and findings are for your own authorized labs and coursework only.
- Keep everything reproducible: configs, prompts and results as files.
