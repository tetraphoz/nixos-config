# Pi configuration resources

This directory holds user-maintained Pi resources, wired in by the Home Manager
module from `pi.nix` in `home/tetra.nix`.

- `skills/<skill-name>/SKILL.md` — reusable, on-demand instructions.
- `extensions/` — local TypeScript extensions; files and subdirectories with
  `index.ts` are loaded by Pi.
- `prompts/*.md` — reusable slash-command prompt templates.
- `agents/*.md` — agent definitions consumed by the bundled subagent extension.

The subagent extension itself is loaded from the examples shipped inside the
selected `pi-coding-agent` package, so it follows the Pi version pinned by this
flake. The sample agents and workflow prompts are kept here so they can be
edited locally; their model frontmatter is omitted so they inherit the active
Pi model.

To add a skill, create a directory containing `SKILL.md`. To add an extension,
put a `.ts` file here or create a subdirectory with an `index.ts`. Add prompt
templates as direct `.md` files in `prompts/`.
