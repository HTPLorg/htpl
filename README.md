# HTPL — Hyper Text Programming Language

HTPL is a full-stack language in HTML format. One `.htpl` file holds
the page, the logic and the server: HTML + CSS + JavaScript +
TypeScript + Python + Node.js infrastructure, in one file.

```html
<htpl>
  <print>Hello, World!</print>
</htpl>
```

Two runtimes, one language: an interpreter in TypeScript
(`htpl run` on Node, `htpl build` emits HTML + CSS + JS for the
browser) and a Rust port that produces the same output. The Rust
runtime also compiles to WebAssembly, so the Playground runs code
in the browser with no server at all.

There is no garbage collector. Memory works like Rust: ownership,
move, borrow, drop. `number`, `bool` and `null` are copied;
`string`, `array` and `object` move; `&x` and `&mut x` borrow.

## Status — v1.0.0

HTPL is at v1.0.0 (2026-11-23). The language is done and verified:

- Full test suite: 41 files, 649 assertions, in both runtimes
- Conformance suite: 154 cases, all green across TypeScript, Rust and WASM
- Language server harness: 58/58

What v1.0.0 includes:

- **Standard library** — 74 callable names (69 distinct behaviours): strings, math, time, collections,
  regex, hashes, seeded random, `load_dotenv`
- **Gadgets** — 13 packages (`ansi`, `greet`, `words`, `hello`,
  `http-client`, `cli`, `config`, `markdown`, `csv`, `crypto`, `time`,
  `html-forms`, `test-utils`), signed with Ed25519, with semver
  ranges, a lockfile and `htpl pm audit`
- **Halo** — the HTPL UI system: 310 utility classes plus 16
  components (button, card, input, table, tabs, dialog, …), one
  theme, dark/light, no JavaScript
- **Async/await** — `<func async="true">` and `<await>`; no Promise
  type; borrows do not survive an await
- **GUI framework** — `<component>` + `<use>`, `<slot />`,
  page-level `<state>` / `<set-state>`, `<stack>` / `<row>` / `<grid>`
- **Native apps** — `htpl app build` packages an app as a native
  app; Linux builds today, macOS / Windows / Android / iOS do not
  yet
- **Tooling** — `htpl fmt` (byte-identical in both runtimes),
  `htpl test`, `htpl repl`, `htpl eval`, a language server and a
  VS Code extension, and a Playground IDE that shares multi-file
  projects as a link
- **Animations** — `<blur-text>`, `<fade-in>`, `<click-spark>`,
  `<glare-hover>`, hand-built, no packages

## The source code is not public yet

This repository holds **no source code**. HTPL is not open-sourced
yet. This repo is the public home of the project: this README, the
license, and the issue templates. Do not expect to find an
interpreter, a compiler, or a binary here.

## Install

There is no working download yet. Saying that plainly:

- **Standalone installer** — exists, but its default download URL is
  not live, so no binary download works today. Until a release is
  published, the installer will fail with "download failed".
- **npm** — not published. The bare name `htpl` is taken on npm by
  an unrelated placeholder; a scoped rename (for example
  `@hvcrealm/htpl`) is still undecided.
- **crates.io** — not published.
- **VS Code Marketplace** — not published.

When a channel goes live, this section will say so, with the exact
command.

## Quickstart

Once HTPL is installed, save this as `hello.htpl`:

```html
<htpl>
  <print>Hello, World!</print>
</htpl>
```

```sh
htpl run hello.htpl        # run it
htpl build hello.htpl      # emit hello.html for the browser
htpl --version             # prints: htpl 1.0.0
```

Other commands: `htpl check`, `htpl fmt`, `htpl test`, `htpl repl`,
`htpl eval "<code>"`, `htpl pm`, `htpl app build`, `htpl lsp`.

## Links

- **Website** — https://htpl.hvcrealm.com — **not deployed yet**.
  The site is built; going live is still pending.
- **Registry** — https://registry.htpl.hvcrealm.com — the static
  registry index. It is index-only and **empty until the first
  sync**; no gadgets are listed there yet.
- **Registry dashboard** — https://app.registry.htpl.hvcrealm.com —
  **live**. This is where gadget publishers register.
- **Playground** — runs on the website once it is deployed; not
  live yet.

## Known limits

- No real-browser or real-VS-Code verification yet (harness-tested
  only); the Playground share link and format-on-save still need a
  human check.
- `crypto`'s `random_token` is not cryptographically secure. Do not
  use it for secrets or tokens.
- Three small runtime divergences remain at the edges (`int()` of a
  digit string too large for i64, very large regex quantifier
  counts, `a{2}{3}`); ordinary programs never hit them.
- NaN / Infinity storage in Rust uses an internal sentinel encoding;
  a user string deliberately constructed to match it would be
  misread. A proper fix is post-1.0 work.
- The sandbox restricts evaluated code only; top-level code keeps
  full power by design, and granted permissions can still be
  misused.

## Issues

Bug reports and feature requests go through this repo's issue
templates. The source is not public, so a bug report cannot link
to the failing code — paste the `.htpl` snippet inline instead,
with the HTPL version, the runtime, and the exact error.

## License

MIT — see [LICENSE](LICENSE).

Copyright (c) 2026 Dr. Harsh Vardhan Chopra.
