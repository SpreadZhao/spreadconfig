# 从 niri 切换到 sway 的调研报告

调研日期：2026-05-18

## 结论

当前仓库不是“把一个窗口管理器包名从 niri 换成 sway”这么简单。现有桌面链路已经深度绑定 niri：

- 登录入口是 `greetd -> niri-session -> systemd --user -> niri.service`。
- Home Manager 显式安装并链接 `niri` 配置。
- `home/modules/systemd.nix` 手写了 `niri.service` 和 `niri-window-detect.service`。
- `swayidle` 的关屏命令直接调用 `niri msg action power-off-monitors`。
- `waybar` 使用 `niri/workspaces`、`niri/window` 和 `scripts/niri/niri_windows.sh`。
- `xdg.desktopEntries`、qutebrowser、zsh alias、截图/录屏/窗口选择/下拉终端都引用 `scripts/niri/*`。
- 仓库里虽然有 `spreadconfig/scripts/sway/`，但它是旧脚本集合，不是完整 sway 配置，也不能直接替代当前 niri 体验。

建议采用渐进迁移：

1. 先新增 sway 配置和 sway 启动链，保留 niri 作为回滚路径。
2. 把通用脚本从 `scripts/niri/` 抽到 `scripts/wayland/` 或 `scripts/util/`。
3. 把确实依赖 compositor IPC 的脚本分别实现 sway 版本。
4. waybar 先替换成 sway 原生模块，跑通后再恢复自定义窗口指示器。
5. 确认 sway 稳定后，再移除 niri 包、niri systemd unit 和 niri 配置目录。

## 当前 niri 相关链路

### 登录和会话启动

`nixos/modules/services/greetd.nix` 当前配置：

```nix
initial_session = {
  command = "niri-session";
  user = "spreadzhao";
};
```

`niri-session` 的行为是：

1. 导入登录环境到 user systemd / D-Bus。
2. `systemctl --user --wait start niri.service`。
3. niri 退出后启动 `niri-shutdown.target`，停止 `graphical-session.target`。

仓库里的 `home/modules/systemd.nix` 又手写了 `niri.service`：

```nix
niri = {
  Unit = {
    BindsTo = [ "graphical-session.target" ];
    Before = [
      "graphical-session.target"
      "xdg-desktop-autostart.target"
    ];
    Wants = [
      "graphical-session-pre.target"
      "xdg-desktop-autostart.target"
      "waybar.service"
    ];
  };
  Service = {
    Slice = "session.slice";
    Type = "notify";
    ExecStart = "${pkgs.niri}/bin/niri --session";
  };
};
```

本机当前 user systemd 中也能看到：

- `niri.service` 来自 `~/.config/systemd/user/niri.service`。
- `niri-window-detect.service` 是 enabled。
- 当前没有 `sway-session.target`。

迁移到 sway 后，这部分必须调整。不能继续让 `greetd` 启动 `niri-session`，也不能保留 `niri-window-detect.service`。

### 包和配置

当前 niri 包和配置在：

- `home/modules/programs/niri.nix`
- `spreadconfig/config/niri/config.kdl`

模块内容：

```nix
home.packages = [ pkgs.niri ];
xdg.configFile."niri".source =
  config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/niri";
```

sway 当前没有对应模块：

- 没有 `home/modules/programs/sway.nix`
- 没有 `nixos/modules/programs/sway.nix`
- 没有 `spreadconfig/config/sway/config`

也就是说仓库当前没有完整 sway 配置。

### PATH 和脚本入口

`home/modules/home-core.nix` 当前把 niri bin 目录放进 PATH：

```nix
sessionPath = [
  "$SCRIPT_HOME/niri/bin"
  "$SCRIPT_HOME/util/bin"
  "$SCRIPT_HOME/nix"
  "$HOME/.local/bin"
];
```

`scripts/niri/bin/fm` 和 `scripts/niri/bin/fm-kitty` 是当前 launcher / dmenu 入口。切到 sway 后，如果继续使用 `fm`，需要：

- 改 `sessionPath` 到新的 sway 或通用 bin 目录。
- 或把 `fm` 从 `scripts/niri/bin` 移到 `scripts/wayland/bin`。
- 或提供 `scripts/sway/bin/fm`。

### XDG desktop entries

`home/modules/xdg.nix` 有多个 niri 相关桌面入口：

```nix
toggle_monitor.exec = "${scriptsDir}/niri/niri_toggle_output.sh";
lock_policy.exec = "${scriptsDir}/niri/lock_policy.sh";
foot_new_tab.exec = "${scriptsDir}/niri/foot_new_tab.sh";
niri_set_dynamic_target.exec = "${scriptsDir}/niri/niri_set_dynamic_target.sh";
niri_focus_window.exec = "${scriptsDir}/niri/niri_focus_window.sh";
```

迁移到 sway 后的处理建议：

- `toggle_monitor`：需要改成 `swaymsg -t get_outputs` + `swaymsg output <name> enable/disable`。
- `lock_policy`：可以保留菜单逻辑，但禁用锁屏后“点亮屏幕”的 `niri msg action power-on-monitors` 要换成 sway 对应输出命令，或者删除这一步。
- `foot_new_tab`：niri 的“把新窗口并入当前 column tab”没有 sway 等价能力，需要改成普通 `footclient`、scratchpad 或 tabbed layout 策略。
- `niri_set_dynamic_target`：niri dynamic cast 是 niri 特有能力，sway/xdg-desktop-portal-wlr 没有直接等价入口。
- `niri_focus_window`：可用 `swaymsg -t get_tree` 重写窗口选择和聚焦。

### swayidle / 锁屏 / 关显示器

当前 `home/modules/services/swayidle.nix`：

```nix
services.swayidle = {
  enable = true;
  timeouts = [
    {
      timeout = 600;
      command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
    }
    {
      timeout = 605;
      command = "${pkgs.swaylock}/bin/swaylock";
    }
  ];
  events = {
    "before-sleep" = lock;
  };
};
```

这在 sway 下必须改掉第一条 timeout。候选方向：

- 使用 sway 输出命令关显示器。
- 或只保留 605 秒锁屏，不做关屏。
- 或用 `swaymsg` 配合 `output * ...` 实现所有输出关屏。

注意：本机当前 `swayidle.service` 还有用户 override drop-in：

```ini
[Service]
ExecStart=
ExecStart=/run/current-system/sw/bin/sleep infinity
```

这是之前“禁止自动锁屏”的临时状态，不是仓库配置本身。真正切换前需要先恢复锁屏策略，否则 sway 下也不会自动锁屏。

### waybar

当前 `spreadconfig/config/waybar/config.jsonc` 直接使用 niri 模块：

```jsonc
"modules-left": [
  "group/niri-workspace-window",
  "custom/screen-record-time"
],
"modules-center": [
  "niri/window"
],
"group/niri-workspace-window": {
  "modules": [
    "niri/workspaces",
    "custom/window-indicator"
  ]
},
"custom/window-indicator": {
  "exec": "/home/spreadzhao/scripts/niri/niri_windows.sh",
  "signal": 8
},
"niri/window": {
  "separate-outputs": true
}
```

迁移到 sway 至少需要改：

```jsonc
"modules-left": [
  "sway/workspaces",
  "sway/mode",
  "custom/screen-record-time"
],
"modules-center": [
  "sway/window"
]
```

同时删除或替换：

- `group/niri-workspace-window`
- `niri/workspaces`
- `niri/window`
- `custom/window-indicator`
- `/home/spreadzhao/scripts/niri/niri_windows.sh`

音频模块当前引用：

```jsonc
"custom/sink": {
  "exec": "/home/spreadzhao/scripts/niri/sink_niri.sh"
},
"custom/source": {
  "exec": "/home/spreadzhao/scripts/niri/source_niri.sh"
}
```

这两个脚本本身不依赖 niri，只是文件名带 niri。建议迁移到 `scripts/util/` 或 `scripts/wayland/`，然后改 waybar 路径。

CSS 里也有 niri 命名：

- `#niri-workspace-window`
- 注释里的 `niri workspaces and windows`
- 注释里的 `niri window indicator`
- 注释里的 `niri window title`

这些需要改成 sway 或通用命名。

### qutebrowser 和 zsh

`spreadconfig/config/qutebrowser/config.py`：

```python
startFloatingFoot = '/home/spreadzhao/scripts/niri/start_floating_foot.sh'
```

`home/modules/programs/zsh.nix`：

```nix
ff = "${scriptsDir}/niri/start_floating_foot.sh";
```

`start_floating_foot.sh` 本身只是启动 `footclient -a lick-foot -T ...`，不依赖 `niri msg`。建议移动到：

- `scripts/wayland/start_floating_foot.sh`
- 或 `scripts/util/start_floating_foot.sh`

然后更新 qutebrowser 和 zsh alias。

## 现有 sway 资源评估

仓库里有 `spreadconfig/scripts/sway/`：

- `auto-start-sway.sh`
- `audio_sway.sh`
- `curr_window_title.sh`
- `get_curr_window_title.sh`
- `get_display_from_click.py`
- `get_display_from_click.sh`
- `scratchpad_count.sh`
- `sway_scratchpad_count.py`

这些不是完整 sway 配置。主要问题：

- 多数脚本是 i3blocks 风格，依赖 `BLOCK_BUTTON`、`BLOCK_X`、`BLOCK_Y`。
- 多处硬编码 `/usr/bin/python` 或 `~/scripts/...`，不符合当前 NixOS/Home Manager 路径管理方式。
- 没有 `spreadconfig/config/sway/config`。
- 没有声明式的 `wayland.windowManager.sway` 或 `programs.sway` 模块。
- 没有与当前 fuzzel、foot、waybar、swayidle、xdg autostart 的完整集成。

可以复用的部分：

- `get_curr_window_title.sh` 的 `swaymsg -t get_tree` 思路。
- `sway_scratchpad_count.py` 的 scratchpad 状态展示思路。
- `get_display_from_click.py` 的“坐标推导输出”逻辑。

不建议直接启用整目录脚本。

## 推荐目标结构

建议把当前 niri/sway 切换做成可回滚结构：

```text
home/modules/programs/
  niri.nix       # 保留到迁移完成
  sway.nix       # 新增
  waybar.nix     # 调整 target 和配置

nixos/modules/programs/
  sway.nix       # 可选，负责系统级 sway/wlroots 集成

spreadconfig/config/
  niri/
  sway/
    config
  waybar/
    config.jsonc
    config-sway.jsonc 或拆分 profiles

spreadconfig/scripts/
  niri/
  sway/
  wayland/ 或 util/
```

其中 `scripts/wayland/` 或 `scripts/util/` 应该放 compositor 无关逻辑，例如：

- 音频状态：`sink_niri.sh`、`source_niri.sh`
- 浮动终端启动：`start_floating_foot.sh`
- fzf dmenu：`fzf_dmenu.sh`
- 截图的区域模式和编辑/OCR后处理

`scripts/niri/` 和 `scripts/sway/` 只保留真正依赖各自 IPC 的逻辑。

## NixOS / Home Manager 方案选择

### 方案 A：Home Manager 管 sway，NixOS 只提供基础权限

使用：

```nix
wayland.windowManager.sway = {
  enable = true;
  systemd = {
    enable = true;
    xdgAutostart = true;
  };
};
```

优点：

- 和当前 niri 的用户配置管理方式更接近。
- `wayland.windowManager.sway.systemd.enable` 会导入 `DISPLAY`、`WAYLAND_DISPLAY`、`SWAYSOCK`、`XDG_CURRENT_DESKTOP`、`XDG_SESSION_TYPE`、`NIXOS_OZONE_WL` 等环境变量。
- 可以让 `wayland.systemd.target = "sway-session.target"`，使 waybar、swayidle、cliphist、fnott、foot server 等 Wayland user services 绑定到 sway 会话。
- 可以用 Home Manager 生成 `~/.config/sway/config`。

缺点：

- 如果用 greetd 直接执行 `sway`，需要确认 user profile PATH 中能找到 Home Manager 安装的 sway。
- 如果不用 Home Manager 生成配置，而是手写 symlink，需要注意手写配置是否启动了 systemd target。

### 方案 B：NixOS `programs.sway.enable = true` 提供系统会话，Home Manager 只放配置

使用：

```nix
programs.sway = {
  enable = true;
  xwayland.enable = true;
};
```

优点：

- sway 在系统 profile 中可用，greetd 可以稳定执行。
- NixOS 模块会创建 `sway-session.target`。
- 会生成 `/etc/sway/config.d/nixos.conf`，其中负责导入环境并启动/停止 `sway-session.target`。
- NixOS 模块会设置 sway 的 portal 默认策略：ScreenCast/Screenshot 走 `wlr`。

缺点：

- 如果同时让 Home Manager 也生成完整 sway config，容易出现“双 owner”。
- 如果自己写 `~/.config/sway/config`，必须 `include /etc/sway/config.d/*`，否则 NixOS 的 systemd integration 不会进入用户配置。

### 推荐

本仓库更适合方案 A 或“方案 A 为主，方案 B 只提供系统包”：

1. 新增 `home/modules/programs/sway.nix`，用 Home Manager 管 `wayland.windowManager.sway`。
2. 设置 `wayland.systemd.target = "sway-session.target"`。
3. 用 Home Manager 管 `~/.config/sway/config`，或者先 symlink `spreadconfig/config/sway`。
4. `greetd.initial_session.command` 改成明确路径或 wrapper，避免 PATH 问题。

不要同时让 NixOS 和 Home Manager 各自生成一份互相覆盖的 sway config。

## 需要新增或修改的文件

### 必须新增

`home/modules/programs/sway.nix`

职责：

- 安装/启用 sway。
- 管理 `~/.config/sway/config`。
- 启用 sway systemd integration。
- 可选：声明 `wayland.systemd.target = "sway-session.target"`。

`spreadconfig/config/sway/config`

职责：

- 输出配置。
- 输入配置。
- keybindings。
- floating rules。
- startup / exec。
- include systemd integration，取决于采用方案。

可选新增：

- `spreadconfig/config/waybar/config-sway.jsonc`
- `spreadconfig/config/waybar/style-sway.css`
- `spreadconfig/scripts/sway/focus_window.sh`
- `spreadconfig/scripts/sway/toggle_output.sh`
- `spreadconfig/scripts/sway/lock.sh`
- `spreadconfig/scripts/sway/screenshot.sh`

### 必须修改

`nixos/modules/services/greetd.nix`

把：

```nix
command = "niri-session";
```

改成 sway 启动命令。候选：

```nix
command = "sway";
```

或者更稳：

```nix
command = "${pkgs.sway}/bin/sway";
```

如果使用 wrapper 脚本：

```nix
command = "${scriptsDir}/sway/start_sway_greetd.sh";
```

`home/modules/systemd.nix`

需要移除或条件化：

- `niri.service`
- `niri-window-detect.service`

polkit agent 可以保留，但最好让它跟随 `config.wayland.systemd.target`，而不是硬编码 `graphical-session.target`。

`home/modules/programs/default.nix`

加入 `./sway.nix`。迁移完成后可移除 `./niri.nix`。

`home/modules/home-core.nix`

把：

```nix
"$SCRIPT_HOME/niri/bin"
```

改成：

```nix
"$SCRIPT_HOME/sway/bin"
```

或更推荐：

```nix
"$SCRIPT_HOME/wayland/bin"
```

`home/modules/services/swayidle.nix`

把 niri 关屏命令替换成 sway 版本。锁屏和 before-sleep 可继续使用 `swaylock`。

`home/modules/programs/waybar.nix`

如果使用 Home Manager 的 waybar systemd integration，建议改成：

```nix
programs.waybar = {
  enable = true;
  systemd.enable = true;
  systemd.targets = [ "sway-session.target" ];
};
```

当前模块是手动安装包并链接 upstream `waybar.service`，可用，但切到 sway 后建议让 target 更明确。

`home/modules/xdg.nix`

替换所有 `scriptsDir}/niri/...` desktop entries。

`spreadconfig/config/qutebrowser/config.py`

替换：

```python
startFloatingFoot = '/home/spreadzhao/scripts/niri/start_floating_foot.sh'
```

`home/modules/programs/zsh.nix`

替换：

```nix
ff = "${scriptsDir}/niri/start_floating_foot.sh";
```

## niri config 到 sway config 的对应关系

### 输出配置

当前 niri：

```kdl
output "eDP-1" {
    scale 2
    position x=5360 y=500
}

output "HDMI-A-1" {
    scale 1
    position x=0 y=0
}

output "DP-2" {
    scale 1
    position x=3440 y=180
    focus-at-startup
}
```

sway 草案：

```conf
output eDP-1 scale 2 position 5360 500
output HDMI-A-1 scale 1 position 0 0
output DP-2 scale 1 position 3440 180
exec swaymsg focus output DP-2
```

niri 的 per-output column width layout 没有 sway 直接等价。

### 输入配置

当前 niri：

```kdl
keyboard {
    numlock
}

touchpad {
    tap
    dwt
    natural-scroll
    accel-speed 0.5
    scroll-factor 0.5
}
```

sway 草案：

```conf
input type:keyboard xkb_numlock enabled
input type:touchpad tap enabled
input type:touchpad dwt enabled
input type:touchpad natural_scroll enabled
input type:touchpad accel_speed 0.5
input type:touchpad scroll_factor 0.5
```

实现时需要用 `swaymsg -t get_inputs` 确认实际设备类型和支持选项。

### 布局

niri 当前核心体验：

- scrolling columns
- 每列可 tab
- `consume-window-into-column`
- `consume-or-expel-window-left/right`
- per-column width presets
- per-window height presets
- `center-column`

sway 没有 scrolling-column 模型。只能映射成：

- workspace
- split container
- tabbed / stacking layout
- floating / scratchpad
- resize grow/shrink

因此以下 niri 快捷键无法等价迁移，只能重设计：

- `consume-window-into-column`
- `expel-window-from-column`
- `consume-or-expel-window-left/right`
- `switch-preset-column-width`
- `switch-preset-window-height`
- `center-column`
- `maximize-column`
- `toggle-column-tabbed-display`

可迁移但语义不同的快捷键：

- `focus-column-or-monitor-left` -> `focus left`
- `focus-window-or-monitor-down` -> `focus down`
- `move-column-left-or-to-monitor-left` -> `move left`
- `move-window-down-or-to-workspace-down` -> `move down` 或 `move container to workspace next`
- `fullscreen-window` -> `fullscreen toggle`
- `toggle-window-floating` -> `floating toggle`

### Window rules

当前 niri 有以下重要规则：

- `dropdown-foot` / `dropdown-kitty` 打开 floating，定位顶部。
- `lick-foot` / `lick-kitty` 打开 floating，用于 launcher / dmenu / editor/file chooser。
- `feh`、`org.qutebrowser.qutebrowser` 不强制 fullscreen。
- `feh title=.*\/tmp.*`、JetBrains Welcome、Satty 打开 floating。
- `wechat title=wechat` 不自动 focus。
- dynamic cast target 用 focus-ring 标记。

sway 可以覆盖大部分 floating 规则：

```conf
for_window [app_id="dropdown-foot"] floating enable, move position 0 0, resize set width 80 ppt height 50 ppt
for_window [app_id="dropdown-kitty"] floating enable, move position 0 0, resize set width 80 ppt height 50 ppt
for_window [app_id="lick-foot"] floating enable, resize set width 75 ppt height 60 ppt
for_window [app_id="lick-kitty"] floating enable, resize set width 75 ppt height 60 ppt
for_window [app_id="com.gabm.satty"] floating enable
for_window [title=".*Welcome.*"] floating enable
```

不能直接迁移的规则：

- `is-window-cast-target=true`
- niri dynamic cast window/monitor target
- niri column-specific width/height defaults

## 快捷键迁移建议

建议先实现一个最小可用 sway keymap：

```conf
set $mod Mod4

bindsym $mod+Return exec footclient
bindsym $mod+Shift+Return exec /home/spreadzhao/scripts/sway/drop_down_foot.sh
bindsym $mod+space exec fuzzel

bindsym XF86AudioRaiseVolume exec wpctl set-volume -l 1.5 @DEFAULT_SINK@ 5%+ && pkill -RTMIN+7 waybar
bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_SINK@ 5%- && pkill -RTMIN+7 waybar
bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && pkill -RTMIN+7 waybar
bindsym XF86AudioMicMute exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && pkill -RTMIN+7 waybar

bindsym XF86MonBrightnessUp exec brightnessctl --class=backlight set +10%
bindsym XF86MonBrightnessDown exec brightnessctl --class=backlight set 10%-

bindsym $mod+d exec swaylock
bindsym $mod+Shift+c kill
bindsym $mod+Shift+q exit

bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
bindsym $mod+3 workspace number 3
bindsym $mod+4 workspace number 4
bindsym $mod+5 workspace number 5
bindsym $mod+6 workspace number 6
bindsym $mod+7 workspace number 7
bindsym $mod+8 workspace number 8
bindsym $mod+9 workspace number 9

bindsym $mod+Shift+1 move container to workspace number 1
bindsym $mod+Shift+2 move container to workspace number 2
bindsym $mod+Shift+3 move container to workspace number 3
bindsym $mod+Shift+4 move container to workspace number 4
bindsym $mod+Shift+5 move container to workspace number 5
bindsym $mod+Shift+6 move container to workspace number 6
bindsym $mod+Shift+7 move container to workspace number 7
bindsym $mod+Shift+8 move container to workspace number 8
bindsym $mod+Shift+9 move container to workspace number 9

bindsym $mod+f fullscreen toggle
bindsym $mod+Shift+f floating toggle
bindsym $mod+t layout tabbed
```

然后再逐步补：

- screenshot
- screenrecord
- cliphist dmenu
- toggle output
- focus window picker
- scratchpad/dropdown terminal

## 截图和录屏

当前截图脚本 `scripts/niri/screenshot.sh` 有三种模式：

- 区域截图：`wayfreeze + slurp + grim`
- 输出截图：通过 `niri msg -j outputs` 选择输出，再 `grim -o`
- 窗口截图：通过 `niri msg -j pick-window` 和 `niri msg -j windows` 获取窗口 rect

迁移建议：

- 区域截图逻辑可以复用。
- 输出截图改为 `swaymsg -t get_outputs`。
- 窗口截图需要重写：用 `swaymsg -t get_tree` 找 focused 或 selected container 的 rect。sway 没有 niri 的 `pick-window` 原生交互，需要自己做窗口列表选择，或者先不实现窗口选择模式。

录屏 `scripts/niri/screenrecord.sh` 基本是 `slurp + wf-recorder`，不依赖 niri，可以移动为通用脚本。

## Portal / 截屏 / 屏幕共享

当前 `home/modules/xdg.nix`：

```nix
xdg.portal.configPackages = [
  xdg-desktop-portal-gnome
];
xdg.portal.extraPortals = [
  xdg-desktop-portal-termfilechooser
];
xdg.portal.config.common.default = [ "gnome" ];
```

这更贴合当前 niri 的 GNOME portal screencast 路径。切到 sway 后，应评估加入：

```nix
pkgs.xdg-desktop-portal-wlr
```

并让 ScreenCast/Screenshot 走 `wlr`。如果启用 NixOS `programs.sway.enable`，NixOS sway 模块已经有 sway portal config：

```nix
xdg.portal.config.sway = {
  default = [ "gtk" ];
  "org.freedesktop.impl.portal.ScreenCast" = "wlr";
  "org.freedesktop.impl.portal.Screenshot" = "wlr";
  "org.freedesktop.impl.portal.Inhibit" = "none";
};
```

但本仓库当前还用了 termfilechooser 作为 FileChooser，所以迁移时要保留：

```nix
"org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
```

## 可以直接保留的部分

这些基本不依赖 niri：

- `swaylock` 配置和 PAM：`home/modules/programs/swaylock.nix`、`nixos/modules/security.nix`
- `fnott`
- `cliphist`
- `foot`
- `fuzzel`
- `satty`
- `grim`
- `slurp`
- `wf-recorder`
- 大部分 util 脚本
- `xdg.autostart.entries` 机制本身
- `clash-verge-rev` autostart
- qutebrowser 主配置，除了外部 editor/file chooser 的 floating terminal wrapper 路径

## 需要重写或替换的 niri 专用文件

强依赖 `niri msg`：

- `scripts/niri/detect_niri_window_change.sh`
- `scripts/niri/drop_down_foot.sh`
- `scripts/niri/drop_down_kitty.sh`
- `scripts/niri/foot_new_tab.sh`
- `scripts/niri/kitty_new_tab.sh`
- `scripts/niri/launcher.sh`
- `scripts/niri/launcher_kitty.sh`
- `scripts/niri/lock_policy.sh`
- `scripts/niri/niri_focus_window.sh`
- `scripts/niri/niri_focused_output_name.sh`
- `scripts/niri/niri_lock.sh`
- `scripts/niri/niri_set_dynamic_target.sh`
- `scripts/niri/niri_toggle_output.sh`
- `scripts/niri/niri_windows.sh`
- `scripts/niri/screenshot.sh` 的 output/window 模式

可移动到通用目录：

- `scripts/niri/screenrecord.sh`
- `scripts/niri/sink_niri.sh`
- `scripts/niri/source_niri.sh`
- `scripts/niri/start_floating_foot.sh`
- `scripts/niri/start_floating_kitty.sh`
- `scripts/niri/fzf_dmenu.sh`
- `scripts/niri/fzf_dmenu_kitty.sh`
- `scripts/niri/fzf_dmenu_preview.sh`

旧 sway 脚本需要整理后才能用：

- `scripts/sway/audio_sway.sh` 需要去掉 `/usr/bin/python` 和 `~/scripts/...`。
- `scripts/sway/curr_window_title.sh` 是 i3blocks signal 逻辑，不适合当前 waybar。
- `scripts/sway/get_curr_window_title.sh` 可作为 waybar `sway/window` 的补充，但 waybar 已有原生 `sway/window`。
- `scripts/sway/sway_scratchpad_count.py` 可以保留为 scratchpad 模块雏形。

## 建议实施步骤

### 阶段 1：并存，不破坏 niri

新增：

- `home/modules/programs/sway.nix`
- `spreadconfig/config/sway/config`
- `spreadconfig/config/waybar/config-sway.jsonc`
- `spreadconfig/scripts/sway/drop_down_foot.sh`
- `spreadconfig/scripts/sway/lock.sh`

暂时保留：

- `home/modules/programs/niri.nix`
- `spreadconfig/config/niri/`
- `scripts/niri/`
- `greetd.initial_session.command = "niri-session"`

验证：

- `nix eval --raw '.#nixosConfigurations.thinkbook.config.system.name'`
- 构建 Home Manager sway config
- 手动在 TTY 里执行 `sway`

### 阶段 2：切换 greetd 默认会话

修改：

- `nixos/modules/services/greetd.nix`

从：

```nix
command = "niri-session";
```

改为：

```nix
command = "sway";
```

或显式路径。

同时：

- 禁用或移除 `home/modules/systemd.nix` 中的 `niri.service`。
- 禁用或移除 `niri-window-detect.service`。
- 确认 `sway-session.target` 存在并被 sway 启动。

### 阶段 3：替换 waybar

修改：

- `spreadconfig/config/waybar/config.jsonc`
- `spreadconfig/config/waybar/style.css`

最低替换：

- `niri/workspaces` -> `sway/workspaces`
- `niri/window` -> `sway/window`
- 删除 `custom/window-indicator`
- 删除 niri window detect service

### 阶段 4：替换 desktop entries 和脚本

修改：

- `home/modules/xdg.nix`
- `home/modules/home-core.nix`
- `home/modules/programs/zsh.nix`
- `spreadconfig/config/qutebrowser/config.py`

把 `scripts/niri/...` 逐个换成：

- `scripts/sway/...`
- 或 `scripts/wayland/...`
- 或 `scripts/util/...`

### 阶段 5：清理 niri

确认 sway 稳定后再删除：

- `home/modules/programs/niri.nix`
- `./niri.nix` import
- `spreadconfig/config/niri/`
- `spreadconfig/scripts/niri/` 中不再需要的文件
- README 中 niri 相关说明

## 风险点

1. niri 的 scrolling-column 工作流无法在 sway 中等价复刻。
2. `foot_new_tab.sh` 依赖 niri column/tab 能力，sway 下要改成 scratchpad 或 tabbed layout。
3. waybar 当前依赖 niri 模块，不替换会直接失效。
4. swayidle 当前关屏命令是 niri IPC，不改会失效。
5. dynamic cast target 是 niri 特有功能，sway 没有直接替代。
6. 如果手写 `~/.config/sway/config`，必须确认 systemd/D-Bus 环境导入，否则 portal、polkit、waybar、cliphist、fnott 可能行为不完整。
7. 当前本机 `swayidle.service` 有禁用锁屏的 user override，切换前要恢复或清理。
8. 旧 `scripts/sway/` 有硬编码 `/usr/bin/python` 和 `~/scripts`，在 NixOS 下不应直接使用。

## 最小可行改动清单

如果目标只是“能登录 sway，并有基本工作环境”，最小清单是：

1. 新增 sway 模块。
2. 新增最小 `spreadconfig/config/sway/config`。
3. greetd 默认会话改成 sway。
4. `swayidle` 关屏命令替换为 sway 命令，或临时移除 600 秒关屏 timeout。
5. waybar 改用 `sway/workspaces` 和 `sway/window`。
6. `home-core.sessionPath` 不再只指向 `scripts/niri/bin`。
7. qutebrowser 和 zsh 的 floating foot wrapper 路径改成通用路径。
8. 禁用 `niri-window-detect.service`。

此时先不要删除 niri，保留回滚。

## 建议最终状态

最终建议状态：

- `programs/` 里保留 `sway.nix`，移除 `niri.nix`。
- `config/sway/` 是唯一窗口管理器配置。
- `scripts/sway/` 只放 sway IPC 脚本。
- `scripts/wayland/` 或 `scripts/util/` 放通用脚本。
- `waybar` 配置不再出现 `niri/*` 模块。
- `swayidle` 不再引用 `pkgs.niri`。
- `greetd` 不再引用 `niri-session`。
- `README.md` 更新为 sway 桌面栈。

