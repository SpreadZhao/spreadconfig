{
  lib,
  pkgs,
  inputs ? { },
  localSkillSource ? (name: ./local + "/${name}"),
  ...
}:

let
  obsidianSkills =
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

  niriComputerUseSkill = {
    niri-computer-use = {
      source = "${inputs.niri-computer-use}/overlay/skills/local/niri-computer-use";
      force = true;
    };
  };

  # draw.io diagramming skill; shared across the agents and Claude targets.
  drawioSkill = {
    drawio-skill.source = "${inputs."drawio-skill"}/skills/drawio-skill";
  };

  wechatArticleFetcherSkill = {
    wechat-article-fetcher = {
      source = localSkillSource "wechat-article-fetcher";
    };
  };

  smartmontoolsDiskHealthSkill = {
    smartmontools-disk-health = {
      source = localSkillSource "smartmontools-disk-health";
    };
  };

  nixosBestPracticesSkill = {
    nixos-best-practices = {
      source = "${inputs."nixos-best-practices-skill"}/skills/nixos-best-practices";
    };
  };

  externalUserSkills = {
    frontend-design = {
      source = inputs."frontend-design-skill";
    };
    web-artifacts-builder = {
      source = inputs."web-artifacts-builder-skill";
    };
    figma-create-design-system-rules = {
      source = "${inputs."openai-skills"}/skills/.curated/figma-create-design-system-rules";
    };
    figma-implement-design = {
      source = "${inputs."openai-skills"}/skills/.curated/figma-implement-design";
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
    };
  };

  codexAgentSkills = {
    android-waydroid-control = {
      source = localSkillSource "android-waydroid-control";
    };
  };

  spreadconfigNixSkill = {
    spreadconfig-nix = {
      source = localSkillSource "spreadconfig-nix";
      force = true;
    };
  };

  secondbrainDiarySkill = {
    secondbrain-diary = {
      source = localSkillSource "secondbrain-diary";
    };
  };

  secondbrainConversationDiarySkill = {
    secondbrain-conversation-diary = {
      source = localSkillSource "secondbrain-conversation-diary";
    };
  };

  wechatDiarySkill = {
    wechat-diary = {
      source = localSkillSource "wechat-diary";
    };
  };

in

{
  # Skill install directories. Keys are Home Manager file targets relative to
  # $HOME, and values can be either one skill attrset or a list of skill
  # attrsets. Later list entries override earlier entries with the same name.
  #
  # Example:
  # skillDirs.".agents/skills" = [
  #   commonSkills
  #   localSkills
  # ];
  #
  # To control missing target directory behavior:
  # skillDirs."path/to/dir/skills" = {
  #   onMissing = "create"; # create | fail | skip
  #   skills = [ commonSkills localSkills ];
  # };
  #
  # Example with an external pinned source:
  # skillDirs.".codex/skills".some-github-skill = "${pkgs.fetchFromGitHub {
  #   owner = "owner";
  #   repo = "repo";
  #   rev = "v1.0.0";
  #   hash = "sha256-...";
  # }}/skills/some-github-skill";
  skillDirs = {
    ".agents/skills" = {
      onMissing = "skip";
      skills = [
        externalUserSkills
        codexAgentSkills
        niriComputerUseSkill
        drawioSkill
        wechatArticleFetcherSkill
      ];
    };

    ".claude/skills" = {
      onMissing = "skip";
      skills = [
        niriComputerUseSkill
        drawioSkill
        wechatArticleFetcherSkill
      ];
    };

    "workspaces/SecondBrain/.agents/skills" = {
      onMissing = "skip";
      skills = [
        obsidianSkills
        secondbrainDiarySkill
        secondbrainConversationDiarySkill
        wechatDiarySkill
      ];
    };

    "workspaces/SecondBrain/.claude/skills" = {
      onMissing = "skip";
      skills = [
        secondbrainDiarySkill
        secondbrainConversationDiarySkill
        wechatArticleFetcherSkill
        wechatDiarySkill
      ];
    };

    "workspaces/spreadconfig/.agents/skills" = {
      onMissing = "skip";
      skills = [
        niriComputerUseSkill
        spreadconfigNixSkill
        smartmontoolsDiskHealthSkill
        # nixosBestPracticesSkill
      ];
    };

    "workspaces/spreadconfig/.claude/skills" = {
      onMissing = "skip";
      skills = [
        niriComputerUseSkill
        spreadconfigNixSkill
        smartmontoolsDiskHealthSkill
      ];
    };
  };
}
