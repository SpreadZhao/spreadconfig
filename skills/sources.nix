{
  lib,
  pkgs,
  inputs ? { },
  ...
}:

let
  # Bundle install for the agents target: the whole skills dir becomes ~/.agents/skills/obsidian-skills.
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

  # Per-skill install for the Claude target: each sub-skill becomes ~/.claude/skills/<name> so
  # Claude Code discovers it as ~/.claude/skills/<skill>/SKILL.md.
  obsidianClaudeSkills =
    if inputs ? "obsidian-skills" then
      {
        defuddle.source = "${inputs."obsidian-skills"}/skills/defuddle";
        json-canvas.source = "${inputs."obsidian-skills"}/skills/json-canvas";
        obsidian-bases.source = "${inputs."obsidian-skills"}/skills/obsidian-bases";
        obsidian-cli.source = "${inputs."obsidian-skills"}/skills/obsidian-cli";
        obsidian-markdown.source = "${inputs."obsidian-skills"}/skills/obsidian-markdown";
      }
    else
      { };

  # draw.io diagramming skill; shared across the agents and Claude targets.
  drawioSkill = {
    drawio-skill.source = "${inputs."drawio-skill"}/skills/drawio-skill";
  };

  wechatArticleFetcherSkill = {
    wechat-article-fetcher = {
      source = ./local/wechat-article-fetcher;
      force = true;
    };
  };

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
  user = obsidianSkills // externalUserSkills // drawioSkill // wechatArticleFetcherSkill;

  # Claude Code skills exposed at ~/.claude/skills. Each entry becomes
  # ~/.claude/skills/<name>; obsidian-skills are installed per-skill so Claude
  # discovers each as ~/.claude/skills/<skill>/SKILL.md.
  claude = obsidianClaudeSkills // drawioSkill // wechatArticleFetcherSkill;

  # Codex-home skills exposed at ~/.codex/skills. Prefer user above for normal
  # personal skills; keep this for compatibility with installers or experiments
  # that explicitly expect CODEX_HOME/skills.
  codex = migratedCodexSkills // wechatArticleFetcherSkill;
}
