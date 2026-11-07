# Bedrock + Agent Pack

The default model path for agent work. Delete this file if the project doesn't use a model, and follow `ai.md` either way: the model sits at the edges, code decides.

## Model

- `[BR-01]` Converse API (`converse`, `converse_stream`) with `toolConfig` for tools. One request shape for every model.
- `[BR-02]` The model comes from `BEDROCK_MODEL_ID`, with no default in code. Newer models need the cross-region inference profile id (`us.` prefix); the bare model id fails on demand.
- `[BR-03]` Auth is IAM through the AWS credential chain: `AWS_PROFILE=hackathon` locally, the app identity when deployed (`aws.md`). No keys in code.
- `[BR-04]` `LLM_PROVIDER=scripted` is the default: a fixed-response provider so the demo path runs cold with no model. `bedrock` is opt-in.
- `[BR-05]` `temperature` 0 for extraction and tool calls. Omit `status` in tool results: only some models accept it.
- `[BR-06]` boto3 blocks. In async code wrap calls in `asyncio.to_thread`.
- `[BR-07]` Settings libraries (pydantic-settings) read `.env` into settings, not the environment, and the AWS SDK only reads the environment. Export `AWS_*` before starting (`uv run --env-file .env`, or `set -a; . ./.env; set +a`).

## Harness

Pick one per project. Each swaps Bedrock for another provider with a one-line change, which is the fallback when Bedrock is down or not allowed.

| Stack | Harness | Fallback provider |
|-------|---------|-------------------|
| Python | Strands Agents (`strands-agents`): Bedrock first, tools are decorated functions, MCP built in | Anthropic API (`ANTHROPIC_API_KEY`) |
| Python, branching flow or LangChain sponsor | LangGraph + `langchain-aws` (`ChatBedrockConverse`) | `langchain-anthropic` |
| TypeScript | AI SDK + `@ai-sdk/amazon-bedrock` | `@ai-sdk/anthropic` |
| Rust | Own tool loop on `aws-sdk-bedrockruntime` Converse | Same loop, Anthropic Messages API |

- `[BR-08]` Tools do the work in plain code and return typed results. Prices, rules, scores and limits come from tools, never from model text.
- `[BR-09]` Cap the loop (about 10 turns) and log every tool call, so a judge can see what the agent did.

## Embeddings + Qdrant

- `[BR-10]` Vectors live in Qdrant (`qdrant/qdrant:v1.20.0`), in Docker locally and on the box (`aws.md`). `QDRANT_URL` from env, no API key: it only listens on 127.0.0.1.
- `[BR-11]` Seed the box's Qdrant through a tunnel, not from the box: `ssh -L 6334:127.0.0.1:6333 ubuntu@<host>`, then run the seed with `QDRANT_URL=http://localhost:6334`.
- `[BR-12]` Embeddings: Titan Text Embeddings V2 (`amazon.titan-embed-text-v2:0`). The model and dimension at query time match the ones the collection was loaded with.
- `[BR-13]` Embed once, in the seed script, never on the demo path. A new account is throttled to about 0.6 calls a second: use adaptive retries and cache what you embed.

## Day 0

- [ ] Model access turned on for the chosen model and Titan V2, in `us-west-2`
- [ ] One `converse` call works as the `hackathon` profile
- [ ] Quotas checked for that model; request an increase if the demo loops
