# 独立 workspace

`spreadconfig` 提供技能目录和 workspace 模板。在自己的 `flake.nix` 中列出需要的技能和工具，运行 `nix develop` 准备入口。

## 初始化

```bash
mkdir my-workspace
cd my-workspace
nix flake init -t github:SpreadZhao/spreadconfig#workspace
# 编辑 flake.nix
nix develop
```

`workspace` 是默认模板；Android 使用 `#android`。开发中央仓库未提交的改动时，可以从本地初始化：

```bash
nix flake init -t "path:$SPREADCONFIG_SOURCE_ROOT#workspace"
nix flake lock --override-input spreadconfig "path:$SPREADCONFIG_SOURCE_ROOT"
nix develop
```

这只更新新 workspace 的锁文件。Git 仓库内的 flake 源文件需要加入 Git，才能被 Git-backed flake 读取。模板的 `.envrc` 可供 direnv 使用。

## 配置

```nix
{
  inputs.spreadconfig.url = "github:SpreadZhao/spreadconfig";
  outputs = { spreadconfig, ... }: spreadconfig.lib.mkWorkspace {
    systems = [ "x86_64-linux" "aarch64-linux" ];
    skills = [
      "leetcode-coach"
      "obsidian-markdown"
    ];
    packages = pkgs: [ pkgs.git pkgs.ripgrep ];
    claude = true;
    instructions = ''
      用中文交流。
    '';
  };
}
```

| 参数 | 用途 |
| --- | --- |
| `systems` | 提供开发环境的平台 |
| `skills` | 从 `skills/sources.nix` 的目录选择技能名称；重复名称会去重 |
| `extraSkills` | 额外技能名称到来源的映射，例如 `{ my-skill = ./skills/my-skill; }`，也可引用上游 flake input 中的目录 |
| `packages` | 进入环境后可用的工具，接受 `pkgs: [ ... ]` 或包列表 |
| `claude` | 额外准备 Claude 入口，默认 `false` |
| `instructions` | 追加到 `AGENTS.md` 的文字 |
| `shellHook` | 追加进入环境时执行的命令 |

输出 `devShells.<system>.default` 和 `checks.<system>.workspace`。技能来源在各自定义中确定：目录中的本地技能使用中央源码，上游技能使用对应的固定来源，`extraSkills` 使用填写的来源。

本地技能通过 `SPREADCONFIG_SOURCE_ROOT` 定位中央 checkout，Home Manager 提供机器默认值；内容修改立即可见。只选择远端或自定义固定来源时，无需此变量。修改技能选择或固定来源后重新进入 `nix develop`。

技能所需的业务路径按技能自己的配置或任务要求提供。

论文阅读的六个技能可以直接列出：

```nix
skills = [
  "run-paper-reading-workflow"
  "ingest-paper"
  "segment-paper"
  "read-paper-sequentially"
  "research-paper-questions"
  "write-obsidian-paper"
];
```

## 生成内容

- `.agents/skills/<name>`：选中的技能入口。
- `AGENTS.md`：技能入口说明和 `instructions`。
- `.agent-workspace/state.json`、`store`：受管理文件记录和 store GC root。
- 启用 Claude 时，`.claude/skills/<name>` 和 `CLAUDE.md` 复用通用入口。

从当前目录向上定位最近的 `flake.nix`，也可通过 `SPREADCONFIG_WORKSPACE_ROOT` 显式指定根目录。移动 workspace 后重新进入即可更新入口并重新注册 GC root。退出 shell 后技能链接仍然可用。

已有用户文件和无关技能会保留。同名目标冲突或来源缺失时，激活会先报错；取消选择只撤销自身记录且来源仍匹配的链接。生成文件的忽略规则保存在 `.gitignore` 的受管理段内。

## 检查

在具体 workspace 内运行 `nix flake check --no-update-lock-file` 检查所选来源。在中央仓库可运行：

```bash
nix build --no-link "path:$PWD#checks.x86_64-linux.workspace-skills"
```

中央仓库只保留 `workspace-skills`，检查所选技能来源中的 `SKILL.md` 是否存在。
