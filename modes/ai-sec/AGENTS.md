# Mode: ai-sec

AI and LLM security testing (AI-RTA, LLM-RTA). Targets are LOCAL models you run
yourself. Never test models or services you are not authorized to test.

## Local target

- Models run on Ollama, bound to 127.0.0.1:11434 (OpenAI-compatible at /v1).
- Start the server:  ollama serve &   (or: sudo systemctl start ollama)
- Pull a target model first, for example:  ollama pull <model>

## What the agent does here

- Help design and run prompt-injection, jailbreak, and RAG-poisoning tests
  against your own local models.
- Use promptfoo to automate red-team probes and score the results.
- Keep tests reproducible: save prompts, configs, and results as files.

## Discipline

- Local, authorized targets only.
- Keep everything offline. Do not send test payloads to third-party services.
