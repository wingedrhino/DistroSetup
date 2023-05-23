# JavaScript Development Setup

## Rules of Engagement

* All code you write must be TypeScript, but only TypeScript that satisifies
  the types-as-comments proposal. You shall not write TypeScript that
  generates code. Never use decorators, enums, or reflect-metadata.
* Use Microsoft VS Code on Linux as your IDE, and use GitHub CoPilot for
  enhanced intelligence.
* All written code should be easy to refactor through the `refactor->rename`
  option within VS Code.
* Do not repeat yourself.
* Use pnpm with Node.js

## Setup Node.js

```bash
corepack enable --install-directory=~/.local/bin
corepack prepare pnpm@latest --activate
mkdir -p ~/.local/pnpm-store
pnpm config set store-dir ~/.local/pnpm-store
```

