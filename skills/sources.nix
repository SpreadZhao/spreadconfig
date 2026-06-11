{
  lib,
  pkgs,
  inputs ? { },
  ...
}:

let
  obsidianSkills =
    if inputs ? "obsidian-skills" then
      {
        obsidian = {
          source = "${inputs."obsidian-skills"}/skills";
          target = "obsidian-skills";
        };
      }
    else
      { };

  externalUserSkills = {
    frontend-design = {
      source = inputs."frontend-design-skill";
      force = true;
    };
    web-artifacts-builder = {
      source = inputs."web-artifacts-builder-skill";
      force = true;
    };
    figma-create-design-system-rules = {
      source = "${inputs."openai-skills"}/skills/.curated/figma-create-design-system-rules";
      force = true;
    };
    figma-implement-design = {
      source = "${inputs."openai-skills"}/skills/.curated/figma-implement-design";
      force = true;
    };
    web-design-guidelines = {
      source = pkgs.runCommand "web-design-guidelines-skill" { } ''
        mkdir -p "$out"
        {
          printf '%s\n' \
            '---' \
            'name: web-design-guidelines' \
            'description: Review UI code for Vercel Web Interface Guidelines compliance. Use when asked to review UI, check accessibility, audit design, review UX, or check a site against best practices.' \
            'metadata:' \
            '  author: vercel' \
            '  upstream: https://github.com/vercel-labs/web-interface-guidelines' \
            '---'
          awk '
            NR == 1 && $0 == "---" {
              in_frontmatter = 1
              next
            }
            in_frontmatter && $0 == "---" {
              in_frontmatter = 0
              next
            }
            !in_frontmatter {
              print
            }
          ' ${inputs."web-interface-guidelines"}/command.md
        } > "$out/SKILL.md"
      '';
      force = true;
    };
  };

  migratedCodexSkills = {
    android-waydroid-control = {
      source = ./local/android-waydroid-control;
      force = true;
    };
  };

in

{
  # User-global skills exposed at ~/.agents/skills.
  #
  # Example:
  # user.my-skill = ./local/my-skill;
  #
  # Example with an external pinned source:
  # user.some-github-skill = "${pkgs.fetchFromGitHub {
  #   owner = "owner";
  #   repo = "repo";
  #   rev = "v1.0.0";
  #   hash = "sha256-...";
  # }}/skills/some-github-skill";
  user = obsidianSkills // externalUserSkills;

  # Codex-home skills exposed at ~/.codex/skills. Prefer user above for normal
  # personal skills; keep this for compatibility with installers or experiments
  # that explicitly expect CODEX_HOME/skills.
  codex = migratedCodexSkills;

  # Machine-wide skills exposed at /etc/codex/skills.
  system = { };
}
