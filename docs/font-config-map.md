# 字体配置全景图

修改字体时参考本文档，所有字体配置分两类：

- **Nix 配置** — 修改 `home/modules/vars.nix` 中的变量后 `nixos-rebuild switch` 即可生效
- **独立配置文件** — 在 `spreadconfig/` 下，需手动编辑对应的配置文件

---

## 一、核心变量定义

**文件：`home/modules/vars.nix`**

### 字体族 (fontFamilies, 行 34-40)

| 变量 | 当前值 | 用途 |
|------|--------|------|
| `fontFamilies.sans` | IBM Plex Sans | UI / 界面字体 |
| `fontFamilies.mono` | Maple Mono NF CN | 终端 / 等宽字体 |
| `fontFamilies.serif` | IBM Plex Serif | 衬线字体 |
| `fontFamilies.emoji` | Noto Color Emoji | Emoji |
| `fontFamilies.nerdMono` | Symbols Nerd Font Mono | Nerd Font 图标 |

### 字号 (fontSizes, 行 84-97)

| 变量 | 当前值 | 用途 |
|------|--------|------|
| `fontSizes.gtk` | 16 | GTK 应用 |
| `fontSizes.qt` | 16 | Qt 应用 |
| `fontSizes.foot` | 16 | Foot 终端 |
| `fontSizes.kitty` | 16 | Kitty 终端 |
| `fontSizes.fuzzel` | 18 | Fuzzel 启动器 |
| `fontSizes.swaylock` | 30 | Swaylock 锁屏 |
| `fontSizes.wayprompt` | 26 | Wayprompt PIN 输入 |
| `fontSizes.fnott.title` | 20 | 通知标题 |
| `fontSizes.fnott.summary` | 19 | 通知摘要 |
| `fontSizes.fnott.body` | 18 | 通知正文 |

### 字体回退链 (fontFallbacks, 行 41-83)

包含 `emoji`、`monospace`、`sansSerif`、`serif` 四条回退链，含完整的 CJK 字体支持。

---

## 二、Nix 配置（变量驱动）

修改 `vars.nix` 中的变量即可控制以下应用：

### 2.1 GTK — `home/modules/gtk.nix:40-41`

```
font.name  = fontFamilies.sans    → IBM Plex Sans
font.size  = fontSizes.gtk        → 16
```

### 2.2 Qt — `home/modules/qt.nix:21-22,30-31`

```
fixed  = fontFamilies.mono + fontSizes.qt  → Maple Mono NF CN, 16
general = fontFamilies.sans + fontSizes.qt  → IBM Plex Sans, 16
```

### 2.3 Kitty — `home/modules/programs/kitty.nix:21-25`

```
font_family       = fontFamilies.mono  → Maple Mono NF CN (含 OT features)
bold_font         = fontFamilies.mono
italic_font       = fontFamilies.mono
bold_italic_font  = fontFamilies.mono
font_size         = fontSizes.kitty    → 16
```

### 2.4 Foot — `home/modules/programs/foot.nix:23`

```
font = fontFamilies.mono + fontSizes.foot, fontFamilies.nerdMono + fontSizes.foot
```

> 注：Foot 的 nix 配置 `enable = false`，实际生效的是 spreadconfig 下的独立配置文件。

### 2.5 Fuzzel — `home/modules/programs/fuzzel.nix:34`

```
font = fontFamilies.mono + fontSizes.fuzzel, fontFamilies.nerdMono, fontFamilies.emoji
```

### 2.6 Swaylock — `home/modules/programs/swaylock.nix:24-25`

```
font      = fontFamilies.sans  → IBM Plex Sans
font-size = fontSizes.swaylock → 30
```

### 2.7 Wayprompt — `home/modules/programs/wayprompt.nix:20`

```
font-regular = fontFamilies.sans + fontSizes.wayprompt → IBM Plex Sans, 26
```

### 2.8 Fnott — `home/modules/services/fnott.nix:40-42`

```
title-font   = fontFamilies.sans + fontSizes.fnott.title    → IBM Plex Sans, 20
summary-font = fontFamilies.sans + fontSizes.fnott.summary  → IBM Plex Sans, 19
body-font    = fontFamilies.sans + fontSizes.fnott.body     → IBM Plex Sans, 18
```

### 2.9 Fontconfig — `home/modules/fonts.nix:10-14`

```
defaultFonts.monospace  = fontFallbacks.monospace
defaultFonts.sansSerif  = fontFallbacks.sansSerif
defaultFonts.serif      = fontFallbacks.serif
defaultFonts.emoji      = fontFallbacks.emoji
```

### 2.10 控制台字体 — `nixos/modules/time-console.nix:7`

```
console font = Terminus (28pt)  — 独立配置，不受 vars.nix 控制
```

---

## 三、独立配置文件（spreadconfig/ 下）

这些文件中的字体是硬编码的，修改时需逐一编辑。

### 3.1 Waybar — `spreadconfig/config/waybar/style.css:6-7`

```css
font-family: Symbols Nerd Font Mono, IBM Plex Sans, IBM Plex Sans SC, ...;
font-size: 20px;
```
- **字体类型**: sans (UI)
- **修改命令示例**: `将 IBM Plex Sans 替换为新字体名`

### 3.2 Wofi — `spreadconfig/config/wofi/style.css:2-3`

```css
font-family: "Noto Sans";
font-size: 25px;
```
- **字体类型**: sans

### 3.3 Foot 终端 — `spreadconfig/config/foot/foot.ini:2`

```ini
font=IBM Plex Mono:size=16, Symbols Nerd Font Mono:size=16
```
- **字体类型**: mono
- **注意**: 使用 IBM Plex Mono 而非 vars.nix 中的 Maple Mono NF CN

### 3.4 Fnott — `spreadconfig/config/fnott/fnott.ini:17-19`

```ini
title-font=IBM Plex Sans:size=20:weight=semibold,IBM Plex Sans SC,...
summary-font=IBM Plex Sans:size=16,...
body-font=IBM Plex Sans:size=14,...
```
- **字体类型**: sans
- **注意**: 字号 (16/14) 与 nix 配置中的字号 (19/18) 不同，这份是实际生效的独立配置

### 3.5 Fuzzel — `spreadconfig/config/fuzzel/fuzzel.ini:17`

```ini
font=IBM Plex Mono:size=18, Symbols Nerd Font Mono:size=18, Noto Color Emoji:size=18
```
- **字体类型**: mono
- **注意**: 使用 IBM Plex Mono 而非 vars.nix 中的 Maple Mono NF CN

### 3.6 Swaylock — `spreadconfig/config/swaylock/config:5-6`

```
font=Noto Sans
font-size=30
```
- **字体类型**: sans
- **注意**: 使用 Noto Sans 而非 vars.nix 中的 IBM Plex Sans

### 3.7 Fontconfig — `spreadconfig/config/fontconfig/fonts.conf`

```xml
sans-serif → Noto Sans + CJK
serif      → Noto Serif + CJK
monospace  → Noto Sans Mono + CJK + Symbols Nerd Font Mono
```
- **注意**: 独立的 fontconfig 文件，使用 Noto 系列而非 vars.nix 中定义的字体

### 3.8 GTK 3 — `spreadconfig/config/gtk-3.0/settings.ini:4`

```ini
gtk-font-name=Noto Sans 16
```

### 3.9 GTK 4 — `spreadconfig/config/gtk-4.0/settings.ini:4`

```ini
gtk-font-name=Noto Sans 16
```

### 3.10 Fcitx5 — `spreadconfig/config/fcitx5/conf/classicui.conf:6-8`

```ini
Font="Noto Sans 18"
MenuFont="Noto Sans 10"
TrayFont="Noto Sans 10"
```
- **字体类型**: sans

### 3.11 Fcitx5 Catppuccin 模板 — `spreadconfig/input/fcitx5-catppuccin/templates/fcitx5.tera:18,67`

```
Font=Sans 13   (输入面板)
Font=Sans 10   (菜单)
```

### 3.12 Qutebrowser — `spreadconfig/config/qutebrowser/config.py:97-111`

```python
c.fonts.default_family = ['Noto Color Emoji', 'Symbols Nerd Font Mono',
    'IBM Plex Sans', 'IBM Plex Sans SC', 'IBM Plex Sans TC', ...]
c.fonts.default_size = '12pt'
```
- **字体类型**: sans (主字体) + mono (部分 UI)

### 3.13 Qutebrowser autoconfig — `spreadconfig/config/qutebrowser/autoconfig.yml:48-52`

```yaml
fonts.default_family: [Noto Sans]
fonts.default_size: 16pt
```

---

## 四、字体包安装 — `home/modules/apps.nix:112-118`

| 包名 | 用途 |
|------|------|
| `noto-fonts` | Noto Sans / Serif / Sans Mono |
| `noto-fonts-cjk-sans` | CJK 无衬线 |
| `noto-fonts-cjk-serif` | CJK 衬线 |
| `noto-fonts-color-emoji` | Emoji |
| `nerd-fonts.symbols-only` | Symbols Nerd Font Mono |
| `maple-mono.NF-CN-unhinted` | Maple Mono NF CN |
| `ibm-plex` | IBM Plex Sans / Serif / Mono |

---

## 五、快速修改指南

### 修改全局 mono 字体

需修改的文件：

| # | 文件 | 位置 | 当前值 |
|---|------|------|--------|
| 1 | `home/modules/vars.nix` | 行 36 `fontFamilies.mono` | Maple Mono NF CN |
| 2 | `spreadconfig/config/foot/foot.ini` | 行 2 | IBM Plex Mono |
| 3 | `spreadconfig/config/fuzzel/fuzzel.ini` | 行 17 | IBM Plex Mono |
| 4 | `spreadconfig/config/fontconfig/fonts.conf` | 行 34 | Noto Sans Mono |

### 修改全局 sans 字体

需修改的文件：

| # | 文件 | 位置 | 当前值 |
|---|------|------|--------|
| 1 | `home/modules/vars.nix` | 行 35 `fontFamilies.sans` | IBM Plex Sans |
| 2 | `spreadconfig/config/waybar/style.css` | 行 6 | IBM Plex Sans |
| 3 | `spreadconfig/config/wofi/style.css` | 行 2 | Noto Sans |
| 4 | `spreadconfig/config/fnott/fnott.ini` | 行 17-19 | IBM Plex Sans |
| 5 | `spreadconfig/config/swaylock/config` | 行 5 | Noto Sans |
| 6 | `spreadconfig/config/fontconfig/fonts.conf` | 行 8 | Noto Sans |
| 7 | `spreadconfig/config/gtk-3.0/settings.ini` | 行 4 | Noto Sans |
| 8 | `spreadconfig/config/gtk-4.0/settings.ini` | 行 4 | Noto Sans |
| 9 | `spreadconfig/config/fcitx5/conf/classicui.conf` | 行 6-8 | Noto Sans |
| 10 | `spreadconfig/config/qutebrowser/config.py` | 行 100 | IBM Plex Sans |
| 11 | `spreadconfig/config/qutebrowser/autoconfig.yml` | 行 50 | Noto Sans |

### 修改全局 serif 字体

| # | 文件 | 位置 | 当前值 |
|---|------|------|--------|
| 1 | `home/modules/vars.nix` | 行 37 `fontFamilies.serif` | IBM Plex Serif |
| 2 | `spreadconfig/config/fontconfig/fonts.conf` | 行 21 | Noto Serif |
