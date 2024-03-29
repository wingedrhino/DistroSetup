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
* Use pnpm with Node.js; and stick to pure ECMAScript Modules. Explicitly
  disallow support for CommonJS and any alternative module loaders.
* Migrate to Deno when Deno's JSX compiler can be told to produce JSX for
  non-React platforms, like [Solid.js](https://www.solidjs.com/).

