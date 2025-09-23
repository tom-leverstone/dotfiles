# Tom's dotfiles

Still to be automated, installing:

- [git-delta](https://github.com/dandavison/delta)
- [codex](https://developers.openai.com/codex/cli/)
    - [playwright-mcp](https://github.com/microsoft/playwright-mcp). I found that installing it with `npm install -g @playwright/mcp@latest` works better than starting the MCP with `npx @playwright/mcp@latest` because it takes less time and thus less prone to startup timeouts.
- [uv](https://docs.astral.sh/uv/)
- [llm](https://llm.datasette.io/en/stable/). Istall w/ `uv tool install llm`.
    - [llm-anthropic](https://github.com/simonw/llm-anthropic). Install w/ `llm install llm-anthropic`.
