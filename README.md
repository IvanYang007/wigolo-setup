# wigolo-setup

wigolo MCP server setup, test suite, and configuration for the Pi coding agent.

## What is wigolo?

[wigolo](https://github.com/KnockOutEZ/wigolo) is a local-first web intelligence layer for AI agents. It provides web search, fetch, crawl, extract, cache, find-similar, research, and autonomous gather loops — all as an MCP server, REST API, or embedded SDK. No API keys, no cloud, $0/query.

## Quick Start

```bash
# Install wigolo globally (requires Node >= 20)
npm install -g --allow-scripts wigolo

# Run setup
npx wigolo init

# Verify installation
wigolo verify --json

# Run a search
wigolo search "your query" --json
```

## Pi MCP Setup

1. Install `pi-mcp-adapter`: `pi install npm:pi-mcp-adapter`
2. Restart Pi to load the extension
3. The `.mcp.json` in this directory configures wigolo as a lazy MCP server

## Run Tests

```bash
cd D:/Github/wigolo-setup
bash test-wigolo.sh
```

Tests validate: search, fetch, extract, crawl, cache, find-similar, research, and agent tools.

## Files

| File | Description |
|------|-------------|
| `.mcp.json` | MCP server config for pi-mcp-adapter |
| `test-wigolo.sh` | Automated test suite for all wigolo tools |
| `SETUP-REPORT.md` | Full setup report with test results | 
