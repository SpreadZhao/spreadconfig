{
  lib,
  pkgs,
  inputs ? { },
  localSkillSource ? (name: ./local + "/${name}"),
  workspaceRoot ? "/home/spreadzhao/workspaces",
  ...
}:

let
  workspaceSkillSource = rel: "${workspaceRoot}/${rel}";
  agentTargets = [
    "agents"
    "claude"
  ];

  obsidianSkills =
    if inputs ? "obsidian-skills" then
      {
        defuddle = {
          source = "${inputs."obsidian-skills"}/skills/defuddle";
          targets = [ "agents" ];
        };
        json-canvas = {
          source = "${inputs."obsidian-skills"}/skills/json-canvas";
          targets = [ "agents" ];
        };
        obsidian-bases = {
          source = "${inputs."obsidian-skills"}/skills/obsidian-bases";
          targets = [ "agents" ];
        };
        obsidian-cli = {
          source = "${inputs."obsidian-skills"}/skills/obsidian-cli";
          targets = [ "agents" ];
        };
        obsidian-markdown = {
          source = "${inputs."obsidian-skills"}/skills/obsidian-markdown";
          targets = [ "agents" ];
        };
      }
    else
      { };

  # draw.io diagramming skill; shared across the agents and Claude targets.
  drawioSkill = {
    drawio-skill = {
      source = "${inputs."drawio-skill"}/skills/drawio-skill";
      targets = agentTargets;
    };
  };

  ytDlpDownloaderSkill = {
    yt-dlp-downloader = {
      source = pkgs.runCommand "yt-dlp-downloader-skill" { } ''
        mkdir -p "$out"
        cp ${inputs."yt-dlp-downloader-skill"}/SKILL.md "$out/SKILL.md"
      '';
      targets = agentTargets;
    };
  };

  wechatArticleFetcherSkill = {
    wechat-article-fetcher = {
      source = localSkillSource "wechat-article-fetcher";
      targets = agentTargets;
    };
  };

  smartmontoolsDiskHealthSkill = {
    smartmontools-disk-health = {
      source = localSkillSource "smartmontools-disk-health";
      targets = agentTargets;
    };
  };

  nixosBestPracticesSkill = {
    nixos-best-practices = {
      source = "${inputs."nixos-best-practices-skill"}/skills/nixos-best-practices";
      targets = agentTargets;
    };
  };

  externalUserSkills = {
    frontend-design = {
      source = inputs."frontend-design-skill";
      targets = [ "agents" ];
    };
    web-artifacts-builder = {
      source = inputs."web-artifacts-builder-skill";
      targets = [ "agents" ];
    };
    figma-create-design-system-rules = {
      source = "${inputs."openai-skills"}/skills/.curated/figma-create-design-system-rules";
      targets = [ "agents" ];
    };
    figma-implement-design = {
      source = "${inputs."openai-skills"}/skills/.curated/figma-implement-design";
      targets = [ "agents" ];
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
      targets = [ "agents" ];
    };
  };

  xiaohongshuSummarizerSkill = {
    xiaohongshu-search-summarizer = {
      source = pkgs.runCommand "xiaohongshu-search-summarizer-skill" { } ''
        cp -R ${inputs."xiaohongshu-summarizer-skill"}/xiaohongshu-search-summarizer "$out"
        chmod -R u+w "$out"
        awk '$0 !~ /^compatibility:/' "$out/SKILL.md" > "$out/SKILL.md.tmp"
        mv "$out/SKILL.md.tmp" "$out/SKILL.md"
      '';
      targets = agentTargets;
    };
  };

  codexAgentSkills = {
    android-waydroid-control = {
      source = localSkillSource "android-waydroid-control";
      targets = [ "agents" ];
    };
  };

  spreadconfigNixSkill = {
    spreadconfig-nix = {
      source = localSkillSource "spreadconfig-nix";
      targets = agentTargets;
      force = true;
    };
  };

  spreadconfigSkillAuthoringSkill = {
    spreadconfig-skill-authoring = {
      source = localSkillSource "spreadconfig-skill-authoring";
      targets = agentTargets;
    };
  };

  paperReaderSkill = {
    paper-reader = {
      source = localSkillSource "paper-reader";
      targets = agentTargets;
    };
  };

  secondbrainDiarySkill = {
    secondbrain-diary = {
      source = localSkillSource "secondbrain-diary";
      targets = agentTargets;
    };
  };

  secondbrainConversationDiarySkill = {
    secondbrain-conversation-diary = {
      source = localSkillSource "secondbrain-conversation-diary";
      targets = agentTargets;
    };
  };

  lectureNoteCompanionSkill = {
    lecture-note-companion = {
      source = localSkillSource "lecture-note-companion";
      targets = agentTargets;
    };
  };

  wechatDiarySkill = {
    wechat-diary = {
      source = localSkillSource "wechat-diary";
      targets = agentTargets;
    };
  };

  leetcodeCoachSkill = {
    leetcode-coach = {
      source = localSkillSource "leetcode-coach";
      targets = agentTargets;
    };
  };

  androidDevSkill = {
    android-dev = {
      source = workspaceSkillSource "rime-android-remote/skills/local/android-dev";
      targets = [ "agents" ];
    };
  };

in

rec {
  skillSets = {
    inherit
      androidDevSkill
      codexAgentSkills
      drawioSkill
      externalUserSkills
      lectureNoteCompanionSkill
      leetcodeCoachSkill
      nixosBestPracticesSkill
      obsidianSkills
      paperReaderSkill
      secondbrainConversationDiarySkill
      secondbrainDiarySkill
      smartmontoolsDiskHealthSkill
      spreadconfigSkillAuthoringSkill
      spreadconfigNixSkill
      wechatArticleFetcherSkill
      wechatDiarySkill
      xiaohongshuSummarizerSkill
      ytDlpDownloaderSkill
      ;
  };

  # Dynamic workspace profiles are not linked by Home Manager directly.
  # They are exposed through a manifest consumed by the agent-skills script,
  # so switching a profile does not require a rebuild.
  workspaceProfiles = {
    leetcode = [
      leetcodeCoachSkill
      secondbrainDiarySkill
      secondbrainConversationDiarySkill
    ];

    notes = [
      obsidianSkills
      lectureNoteCompanionSkill
      paperReaderSkill
      secondbrainDiarySkill
      secondbrainConversationDiarySkill
      wechatArticleFetcherSkill
      wechatDiarySkill
      xiaohongshuSummarizerSkill
    ];

    nixos = [
      spreadconfigNixSkill
      spreadconfigSkillAuthoringSkill
      smartmontoolsDiskHealthSkill
      nixosBestPracticesSkill
    ];

    android = [
      androidDevSkill
      codexAgentSkills
    ];

    frontend = [
      externalUserSkills
    ];
  };

  # Home-global skills. Each skill declares its own target directories with the
  # `targets` field: agents -> ~/.agents/skills, claude -> ~/.claude/skills,
  # codex -> ~/.codex/skills.
  globalSkills = [
    drawioSkill
    ytDlpDownloaderSkill
  ];
}
