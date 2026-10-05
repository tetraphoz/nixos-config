# Pi configuration resources

This directory holds user-maintained Pi resources, wired in by the Home Manager
module from `pi.nix` in `home/tetra.nix`.

- `skills/<skill-name>/SKILL.md` — reusable, on-demand instructions.
- `extensions/` — local TypeScript extensions; files and subdirectories with
  `index.ts` are loaded by Pi.
- `prompts/*.md` — reusable slash-command prompt templates.
- `agents/*.md` — agent definitions consumed by the bundled subagent extension.

The subagent extension is linked into Pi's conventional user extension
folder from the examples shipped inside the selected `pi-coding-agent`
package, so it follows the Pi version pinned by this flake. This lets spawned
Pi subprocesses discover it too. Its `/implement`, `/implement-and-review`,
and `/scout-and-plan` workflows are supplied by the extension. The sample agent
profiles are maintained here; their model frontmatter is omitted so they
inherit the active Pi model.

An agent profile with an explicit `tools:` allowlist must include `subagent` if
it should delegate recursively. Use that capability deliberately: recursive
or parallel delegation can multiply model usage quickly.

To add a skill, create a directory containing `SKILL.md`. To add an extension,
put a `.ts` file here or create a subdirectory with an `index.ts`. Add extra
prompt templates as direct `.md` files in `prompts/`. Avoid duplicating
commands already supplied by extensions; Pi reports prompt-name collisions and
keeps the extension-provided template.
