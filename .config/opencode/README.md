# Installing

1. [Opencode](https://opencode.ai) (Can be install via direct cUrl or any package manager)

# Understading opencode.json file
>
> Current setup contains Gateway method to connect with all the models and some MCP setup

## GenAI Gateway

```json
  "provider": {
    "$NAME": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "$NAME",
      "options": {
        "baseURL": "$GATEWAY_URL",
        "apiKey": "{env:API_KEY}"
      },
      "models": {
        "$MODEL_NAME": {
          "name": "$MODEL_NAME"
        }
      }
    },
  }

```

## MCP Setup
>
> currently there's multiple method to authrozation, example below

```json
  "mcp": {
    "API Key Method": {
      "type": "remote",
      "url": "$MCP_URL",
      "enabled": true,
      "headers": {
        "API_KEY": "{env:API_KEY}"
      }
    },
    "OAUTH Method": {
      "type": "remote",
      "url": "$MCP_URL",
      "enabled": true,
      "oauth": {}
    },
    "figma": {
      "type": "remote",
      "url": "$MCP_URL",
      "enabled": true,
      "oauth": {
        "clientId": "{env:CLIENT_ID}",
        "clientSecret": "{env:CLIENT_SECRET}"
      }
    }
  }
```

As of now I have 4 main MCP

- [Context 7](https://github.com/upstash/context7?tab=readme-ov-file#installation)

> Authenticate via API_KEY generated in [Dashboard](https://context7.com/dashboard)

- Alassian

>Authenticate via cli command `opencode mcp auth atlassian`

- Gitlab

> Authenticate via cli command `opencode mcp auth gitlab`

- Figma

> Since Figma still don't fully support opencode, we hack the authentication
  via [This hack](https://github.com/anomalyco/opencode/issues/988#issuecomment-4022520800)

# Agents

I build the agent workflow by using [Plan](agent/plan.md) as a main
orchestrator and the rest of the agent will be subagent specialized in their
own field

And each subagent will utilize [skill](skill) and [rules](rules)

# Misc

## [Peon ping](https://www.peonping.com)
>
> If you want to spice your agent notification, this plugin will imitate
> Warcraft minion sound

## [Plannotator](https://github.com/backnotprop/plannotator?tab=readme-ov-file#install-for-opencode)

> Web UI for RFC style plan comment before proceeding with implementation

## [Caveman](https://github.com/JuliusBrussee/caveman)

> Rule to make agent only output necessary word
