import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const gatewayUrl = process.env.AI_GATEWAY_URL?.trim();

const sharedModelConfig = {
  input: ["text"],
  contextWindow: 1000000,
  maxTokens: 128000,
} as const;

const reasoningModelConfig = {
  ...sharedModelConfig,
  reasoning: true,
} as const;

const geminiFlashModelConfig = {
  input: ["text"],
  contextWindow: 1048576,
  maxTokens: 65536,
  cost: {
    input: 0.375,
    output: 1.875,
    cacheRead: 0.0375,
    cacheWrite: 0.0208333333333,
  },
} as const;

const grokModelConfig = {
  input: ["text"],
  contextWindow: 500000,
  maxTokens: 128000,
  cost: {
    input: 2,
    output: 6,
    cacheRead: 0.5,
    cacheWrite: 0,
  },
  tiers: [
    {
      inputTokensAbove: 200000,
      input: 4,
      output: 12,
      cacheRead: 1,
      cacheWrite: 0,
    },
  ],
} as const;

const sonnetModelConfig = {
  ...reasoningModelConfig,
  cost: { input: 2, output: 10, cacheRead: 0.2, cacheWrite: 2.5 },
} as const;

const opusModelConfig = {
  ...reasoningModelConfig,
  cost: { input: 5, output: 25, cacheRead: 0.5, cacheWrite: 6.25 },
} as const;

const lunaModelConfig = {
  ...reasoningModelConfig,
  cost: { input: 1, output: 6, cacheRead: 0.1, cacheWrite: 1.25 },
  tiers: [
    {
      inputTokensAbove: 272000,
      input: 2,
      output: 9,
      cacheRead: 0.2,
      cacheWrite: 2.5,
    },
  ],
} as const;

const terraModelConfig = {
  ...reasoningModelConfig,
  cost: { input: 2.5, output: 15, cacheRead: 0.25, cacheWrite: 3.125 },
  tiers: [
    {
      inputTokensAbove: 272000,
      input: 5,
      output: 22.5,
      cacheRead: 0.5,
      cacheWrite: 6.25,
    },
  ],
} as const;

const solModelConfig = {
  ...reasoningModelConfig,
  cost: { input: 5, output: 30, cacheRead: 0.5, cacheWrite: 6.25 },
  tiers: [
    {
      inputTokensAbove: 272000,
      input: 10,
      output: 45,
      cacheRead: 1,
      cacheWrite: 12.5,
    },
  ],
} as const;

export default function registerGatewayModels(pi: ExtensionAPI) {
  if (!gatewayUrl) {
    console.warn("Gateway models disabled: AI_GATEWAY_URL is not set.");
    return;
  }

  pi.registerProvider("gateway", {
    baseUrl: gatewayUrl,
    api: "openai-completions",
    apiKey: "$GENAI_API_KEY",
    models: [
      {
        id: "claude-sonnet-5",
        name: "claude-sonnet-5",
        ...sonnetModelConfig,
      },
      {
        id: "claude-opus-5",
        name: "claude-opus-5",
        ...opusModelConfig,
      },
      {
        id: "gpt-5.6-luna",
        name: "gpt-5.6-luna",
        api: "openai-responses",
        ...lunaModelConfig,
      },
      {
        id: "gpt-5.6-terra",
        name: "gpt-5.6-terra",
        api: "openai-responses",
        ...terraModelConfig,
      },
      {
        id: "gpt-5.6-sol",
        name: "gpt-5.6-sol",
        api: "openai-responses",
        ...solModelConfig,
      },
      {
        id: "gemini-3.7-flash",
        name: "gemini-3.7-flash",
        ...geminiFlashModelConfig,
      },
      {
        id: "grok-4.6",
        name: "grok-4.6",
        ...grokModelConfig,
      },
      {
        id: "kimi-k2.7-code",
        name: "kimi-k2.7-code",
        ...sharedModelConfig,
      },
    ],
  });

  pi.on("before_provider_request", (event, ctx) => {
    if (
      !["openai-gateway", "google-gateway", "xai-gateway"].includes(
        ctx.model?.provider ?? "",
      ) ||
      ctx.model.api !== "openai-responses" ||
      typeof event.payload !== "object" ||
      event.payload === null ||
      Array.isArray(event.payload)
    ) {
      return;
    }

    return { ...event.payload, store: true };
  });
}
