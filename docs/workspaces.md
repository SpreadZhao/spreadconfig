# 独立 workspace

通用安装引擎与模板位于本地独立仓库 `../agent-workspace`；个人技能内容位于
`../personal-skills`。spreadconfig 保留目录、第三方来源加工、使用选择和 Android 模板。
`spreadconfig.lib.mkWorkspace` 是兼容包装，向独立管理器传入本仓库的 catalog。

## 本地初始化

当前两个新仓库尚未发布远端，spreadconfig 的新 inputs 使用绝对本地路径。

```bash
mkdir my-workspace
cd my-workspace
# 使用 spreadconfig 的技能目录：
nix flake init -t path:/home/spreadzhao/workspaces/spreadconfig#workspace
nix flake lock --override-input spreadconfig path:/home/spreadzhao/workspaces/spreadconfig
nix develop path:$PWD
```

Android 改用 `#android`。完全独立、无个人预设的项目使用
`path:/home/spreadzhao/workspaces/agent-workspace#workspace`，并将模板的
agent-workspace input 覆盖为该本地路径。
只有模板与 nix develop 初始化方式。Git 仓库中需要跟踪 flake 文件，
或使用 path: 引用读取未跟踪内容；不要为求值修改用户已有 index。

## 配置

```nix
{
  inputs.spreadconfig.url = "path:/home/spreadzhao/workspaces/spreadconfig";
  outputs = { spreadconfig, ... }: spreadconfig.lib.mkWorkspace {
    systems = [ "x86_64-linux" "aarch64-linux" ];
    skills = [ "leetcode-coach" "obsidian-markdown" ];
    packages = pkgs: [ pkgs.git pkgs.ripgrep ];
    claude = true;
    instructions = "用中文交流。";
    # 已有 AGENTS.md 时可以关闭管理：
    # manageInstructions = false;
  };
}
```

| 参数 | 功能与默认值 |
| --- | --- |
| catalog | 包装器默认提供 spreadconfig 目录；也接受 pkgs: catalog |
| skills | 显式选择名称，默认空，重复选择去重 |
| extraSkills | 额外名称到来源映射，自动选择；目录同名时报错 |
| targets | enable/path；agents 默认开启，Claude/Codex 默认关闭；支持自定义目标 |
| mode | symlink 或 copy，默认 symlink |
| onConflict | error 或 skip，项目默认 error，本机默认 skip |
| cleanup | 清理未修改的受管理撤选入口；项目默认 true，本机默认 false |
| systems | 默认 x86_64-linux 与 aarch64-linux |
| packages | pkgs: 包列表或直接包列表 |
| shellHook | 初始化成功后执行的额外命令 |
| claude | 默认 false；Claude 目标预设和 CLAUDE.md 链接；显式 targets 可覆盖预设 |
| workspaceRoot | 默认向上找最近 flake.nix；可填绝对字符串路径 |
| autoActivate | 默认 true，进入环境时准备入口 |
| instructions | 追加到 AGENTS.md 的文字 |
| manageInstructions | 默认 true；生成 AGENTS.md，Claude 开启时生成 CLAUDE.md 链接 |
| manageGitignore | 默认 true；仅维护自己的忽略块 |

来源记录为 `{ source = input; subdir = "skills/name"; targets = [ "agents" ]; }`。
subdir、targets 均可省略；未指定 targets 时使用所有开启目标。
路径或 derivation 也可直接作为来源。个人技能和第三方输入均通过 flake.lock 固定。
修改个人内容后更新 spreadconfig 的 personal-skills input，下游再更新 spreadconfig input。
不再读取 SPREADCONFIG_SOURCE_ROOT 或 SPREADCONFIG_WORKSPACE_ROOT。
技能所需业务路径仍由具体技能或任务指定。

## 状态与迁移

项目状态为 `.agent-workspace/state.json`，GC roots 位于 `.agent-workspace/roots/`。
退出环境后 store 来源仍保留。安装使用并发目录锁和原子写入。
已有完全一致结果不变；目标变化时先报告冲突，不能自动覆盖。
`error` 在技能、指令及撤选操作全部预检通过前不写入。
`skip` 保留冲突目标并安装其他缺失项，不接管跳过的外部入口。
`cleanup` 仅删除有记录且内容未修改的撤选入口。
非管理器生成的 AGENTS.md 默认冲突，可关闭指令管理或选择 skip。

支持旧 v2 状态与旧忽略块，但来源切换不会隐式覆盖旧链接。
此次内容迁移后，旧 skills/local 来源及旧 Claude 间接链接可能冲突。
按报错检查并移除指定旧入口，再进入开发环境；不要删除整个 skills 父目录。

## 检查

```bash
nix build --no-link path:$PWD#checks.x86_64-linux.workspace-skills
```

检查所选来源的 SKILL.md frontmatter、名称、描述与目标合法性。
管理器自身另有运行时与 Nix API 测试。Android 继续由本仓库提供，
官方技能发现使用管理器的 lib.discoverSkills。
