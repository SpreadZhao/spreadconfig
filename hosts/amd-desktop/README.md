# amd-desktop

为 Ryzen 9 9950X3D + Radeon RX 9070 XT 准备的台式机 host。
目前是待新机硬件信息补齐的配置骨架；磁盘占位模块会主动阻止系统构建和安装。

## 配置复用

- `flake.nix` 的 `mkHost` 自动导入全部 `modules/nixos`、`modules/home`，以及现有 Home Manager、SOPS 和应用输入。
- 本机复用 nixos-hardware 的 `common-cpu-amd` 和 `common-gpu-amd`，提供 AMD 微码、AMDGPU 提前加载和 Mesa 64/32 位图形支持；本地只补充固件、KVM、OpenCL 和 LACT。
- 沿用共享内核、ROCm/Ollama、桌面、开发工具和应用；不需要复制 thinkbook 或 zephyrus-m16 的系统配置。
- 不导入笔记本的 TLP、ASUS 服务、Intel/NVIDIA PRIME 和电池策略。
- 保留共享的 NixOS/Home Manager `stateVersion = "25.11"`。这控制兼容性默认值，不限制软件版本；无需随更新改动。
- 外部配置和脚本按 `spreadconfig/{config,scripts}/default` → `<host>` 合并。共享 Waybar 默认不显示电池和未确认的温度传感器。

准备时锁定的版本是 Linux 6.18.49、Mesa 26.2.2、ROCm 7.2.3、Ollama 0.33.1；实际版本以安装时的 `flake.lock` 为准。
AMD 图形配置依据 [NixOS AMD GPU 文档](https://wiki.nixos.org/wiki/AMD_GPU)。
RX 9070 XT 的 ROCm 架构是 `gfx1201`，见 [AMD 兼容性说明](https://rocm.docs.amd.com/projects/install-on-linux/en/docs-7.0.1/reference/system-requirements.html)。
保留现有 Ollama ROCm 配置，是否实际使用独显需要到机后验证；不要预设 `HSA_OVERRIDE_GFX_VERSION` 或 GPU 序号。

## nixos-hardware 复用范围

| 模块 | 作用 | 本机选择 |
| --- | --- | --- |
| `common-cpu-amd` | 根据固件开关默认启用 AMD 微码更新 | 已导入 |
| `common-gpu-amd` | modesetting、64/32 位图形加速、initrd 加载 AMDGPU | 已导入 |
| `common-cpu-amd-pstate` | 包含 `common-cpu-amd`，在当前内核上显式设置 `amd_pstate=active` | 暂不导入，保留默认电源管理策略 |
| `common-pc-ssd` | 默认启用定期 `fstrim` | 确定 SSD 和存储方案后可导入 |

这些模块是通用默认值，不能替代新机生成的磁盘配置，也不包含 9950X3D 的游戏 CCD 调度策略。当前锁定版本没有找到 9950X3D / RX 9070 XT 专用模块。主板型号确定后，再检查是否有对应适配（例如库中有 `gigabyte-b650` 的休眠修复，不能泛用于其他 AM5 主板）。
模块源码见 [AMD CPU](https://github.com/NixOS/nixos-hardware/blob/master/common/cpu/amd/default.nix)、[AMD GPU](https://github.com/NixOS/nixos-hardware/blob/master/common/gpu/amd/default.nix)、[P-State](https://github.com/NixOS/nixos-hardware/blob/master/common/cpu/amd/pstate.nix) 和 [SSD](https://github.com/NixOS/nixos-hardware/blob/master/common/pc/ssd/default.nix)。

## 新机到手后

以下安装命令只在新台式机的安装环境执行。主板、网卡、磁盘、加密和显示器型号尚未确定。

1. 用 NixOS x86_64 UEFI 安装介质启动，按实际需求分区、格式化，并将目标根分区挂到 `/mnt`，EFI 分区挂到 `/mnt/boot`。加密、Btrfs 子卷、独立 `/home` 和 swap 如需要，也在生成硬件配置前准备好。
2. 把包含本次改动的仓库放到 `/mnt/home/spreadzhao/workspaces/spreadconfig`。安装后的固定路径必须是 `/home/spreadzhao/workspaces/spreadconfig`，因为应用配置和脚本引用这里的文件。
3. 根据已经挂载的真实磁盘生成硬件配置，并替换占位文件：

   ```bash
   sudo nixos-generate-config --root /mnt
   sudo cp /mnt/etc/nixos/hardware-configuration.nix \
     /mnt/home/spreadzhao/workspaces/spreadconfig/hosts/amd-desktop/hardware-configuration.nix
   ```

   检查生成文件的根分区、EFI 分区、文件系统类型、swap 和所需模块。CPU/GPU 的人工策略继续放在 `nixos/hardware.nix`。

4. 配置下面的 SOPS 新机身份，确保最新的 `.sops.yaml` 和重加密后的 `secrets/secrets.yaml` 都已同步到安装用仓库。
5. 在安装用仓库里验证并安装：

   ```bash
   cd /mnt/home/spreadzhao/workspaces/spreadconfig
   git add hosts/amd-desktop/hardware-configuration.nix
   nix eval --raw .#nixosConfigurations.amd-desktop.config.system.build.toplevel.drvPath
   sudo nixos-install --flake .#amd-desktop
   ```

6. 首次启动后确认仓库由 `spreadzhao` 所有；恢复需要的个人数据、密码库和应用登录状态。配置复用不会复制浏览器资料、Ollama 模型或密码库。

日后在新机上使用 `~/scripts/nix/sns_until switch`；内核等启动相关变更使用 `~/scripts/nix/sns_until boot`。

## SOPS 新机身份

共享配置通过 `/etc/ssh/ssh_host_ed25519_key` 解密用户密码哈希和令牌。
新机需要自己的密钥，现有两台机器的公钥不能替代它。

在安装环境生成目标系统的 SSH host key；若该路径已有密钥，保留原密钥：

```bash
sudo install -d -m 0700 /mnt/etc/ssh
sudo test -f /mnt/etc/ssh/ssh_host_ed25519_key || \
  sudo ssh-keygen -t ed25519 -N '' -f /mnt/etc/ssh/ssh_host_ed25519_key
```

把 `.pub` 公钥传到能解密现有 SOPS 文件的旧电脑，然后：

```bash
nix shell nixpkgs#ssh-to-age -c ssh-to-age -i /path/to/new-host-key.pub
```

将输出的 age 公钥加入 `.sops.yaml` 的 `keys`，例如命名为 `host_amd_desktop`，并加入对应 `creation_rules.key_groups.age`。在旧电脑仓库内使用已有管理员身份执行：

```bash
sops updatekeys secrets/secrets.yaml
```

只同步公钥配置和加密文件；SSH 私钥保留在新机目标磁盘。不能只改 `.sops.yaml` 而遗漏 `sops updatekeys`。

## 到机后验证

- `lspci -nnk`：检查显卡使用 `amdgpu`，并核对网卡型号和驱动。
- `clinfo`、`lact`：检查 GPU/OpenCL 识别。运行已有本地模型时用 `ollama ps` 检查 GPU 使用情况，并查看 `journalctl --user -u ollama`。
- `niri msg outputs`：确认实际接口、分辨率、刷新率和缩放。当前继承的 `spreadconfig/config/default/niri/config.kdl` 仍含原桌面的 `eDP-1`、`HDMI-A-1`、`DP-2` 布局；正式使用前按新显示器在 `spreadconfig/config/amd-desktop/niri/` 中覆盖。不要改共享文件来适配新机。
- 如需温度栏，确认 `sensors`/hwmon 对应关系后，在 `spreadconfig/config/amd-desktop/waybar/` 增加配置，不套用旧机传感器路径。
- 9950X3D 先使用内核默认调度；主板 BIOS/CPPC、游戏缓存 CCD 偏好和性能调优留到真实负载测试后决定。参考 [内核 AMD P-State 文档](https://docs.kernel.org/admin-guide/pm/amd-pstate.html)。

这台机器尚未实机验证启动、显卡输出、网络、休眠或 GPU 推理。

## 已完成的配置检查（2026-09-08）

- 三个 host 的 Home Manager activation package 均求值通过。
- 新 host 在临时测试表达式中替换磁盘占位模块后，系统 toplevel 求值通过；测试磁盘声明没有写入实际配置，也未构建或安装系统。
- 正常入口在未替换硬件文件时按预期拒绝系统构建；格式、脚本静态检查及共享桌面配置语法检查通过。
