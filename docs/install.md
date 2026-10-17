# 新电脑安装：NixOS、SOPS 与 Password Store

完整顺序是：**制作安装 U 盘 → Live 环境联网、配置代理和镜像 → cfdisk 分区、
格式化并挂载 → 克隆 spreadconfig → 初始化 SOPS → 安装并启动 NixOS →
克隆 Password Store → 恢复 GPG 私钥 → 再构建并激活一次系统。**

第一次安装不需要 `~/.password-store`，但必须先准备 SOPS 身份。
这两套密钥独立，不能相互替代：

| 身份 | 用途 | 恢复材料 | 本机保存位置 |
| --- | --- | --- | --- |
| SOPS / age | 系统登录密码哈希、GitHub token、GLM API key | `secrets/shared-age-key.age` 和它的解锁口令 | `/var/lib/sops-nix/key.txt` |
| GPG / pass | Password Store 中的密码和应用凭据 | GPG 私钥备份和私钥口令；公钥、`.gpg-id` 本身不能解密 | `~/.gnupg` |

本文沿用本仓库的 `spreadzhao` 用户、私有仓库和目录约定，面向给自己新增电脑或重装。
其他用户 fork 后，需要先修改用户名、Home Manager 用户入口、固定路径和凭据配置，
并换成自己的 SOPS/GPG 身份；不要直接使用这里的个人凭据。
按顺序执行各步骤，命令失败时先解决错误，不要继续安装或重启。

## 1. 安装前准备

准备好：

- NixOS 安装 U 盘，使用 UEFI 模式启动。
- 可用网络；安装环境需要能下载 flake inputs 和 Nix 二进制缓存。
- 如果网络需要代理，提前准备一个可访问的 HTTP / mixed 代理地址。
  可以使用同一局域网内另一台电脑或手机提供的代理，并在对方开启允许局域网连接。
- 本仓库的完整副本，包含 `flake.lock`、`.sops.yaml`、
  `secrets/secrets.yaml` 和 `secrets/shared-age-key.age`。
- SOPS 加密身份的解锁口令、系统登录密码，以及稍后恢复 pass 使用的 GPG 私钥口令。
  三者用途不同，不要求相同；安装前应能在密码仓库之外取得它们。
- 一份可访问的 Password Store 及其 GPG 私钥备份。

现有配置使用 systemd-boot，以下磁盘示例适用于 UEFI + ext4。
双系统、LUKS、Btrfs 子卷或单独的 `/home` 应先按自己的布局挂载完成，再继续第 3 步。

### 下载 ISO，制作启动 U 盘

从 [NixOS 下载页](https://nixos.org/download/)或
[清华 NixOS 镜像目录](https://mirrors.tuna.tsinghua.edu.cn/nixos-images/)选择当前受支持版本。
本仓库现有主机使用 `x86_64-linux`，可选带 Plasma / GNOME 的图形镜像，方便联网；
熟悉命令行也可选 minimal。最终安装的桌面和软件由 spreadconfig 决定，
不会因为启动了 GNOME 安装镜像就安装 GNOME。

下载 ISO 及其对应校验文件，按发布页提供的 SHA256 校验值核对镜像。Linux 下可先计算：

```sh
sha256sum nixos-xxx-x86_64-linux.iso
```

使用 Ventoy / Rufus 制作启动盘，或在 Linux 上写入整块 U 盘设备：

```sh
lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS,MODEL
sudo dd if=nixos-xxx-x86_64-linux.iso of=/dev/sdX bs=4M conv=fsync status=progress
```

把 ISO 文件名和 `/dev/sdX` 替换为实际值。目标必须是已卸载分区的 **U 盘整盘**，
不是 `/dev/sdX1`，也不是待安装系统的硬盘；写入会清除 U 盘原有内容。

## 2. Live 环境联网、加速下载并准备目标磁盘

在安装环境打开终端，进入 root shell：

```sh
sudo -i
test -d /sys/firmware/efi && echo 'UEFI 启动正常'
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
```

没有输出“UEFI 启动正常”时，先以 UEFI 模式重新启动安装介质。
从这里开始，到第 6 步重启之前，始终在 Live 环境的这个 root shell 中操作。

### 2.1 连接网络

有线网络通常自动获取地址；Wi-Fi 用图形桌面的网络设置连接。
安装介质有 NetworkManager 时，也可以运行 `nmtui`，选择“Activate a connection”连接网络。
minimal 镜像若没有 NetworkManager，按
[NixOS 手动安装说明](https://nixos.org/manual/nixos/stable/#sec-installation-manual)的无线网络步骤连接。

```sh
ip -brief address
ip route
```

确认网卡已获得地址，存在默认路由，然后配置代理和下载镜像。

### 2.2 配置首次安装使用的代理

如果 GitHub 和下载地址均可直接访问，可跳过本小节。
下面用 `http://192.168.1.10:7897` 举例，必须替换为实际能连接的 HTTP / mixed 代理地址。
`192.168.1.10` 指提供代理的那台设备；对方需要允许局域网访问，并放行该端口。
只有代理程序确实运行在 Live 系统上时，才使用 `127.0.0.1`。

先给当前终端及其后续的 Git、curl、Nix 安装命令配置代理：

```sh
export http_proxy='http://192.168.1.10:7897'
export https_proxy="$http_proxy"
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export no_proxy='localhost,127.0.0.1,::1,mirrors.ustc.edu.cn,mirrors.tuna.tsinghua.edu.cn'
export NO_PROXY="$no_proxy"
curl -I --connect-timeout 10 https://github.com
```

`https_proxy` 的值仍然可以是 `http://`：这里填写的是代理服务的协议。
`no_proxy` 让本机地址和国内镜像直接连接。连接失败时，先检查代理地址、端口、
局域网访问权限和防火墙，不要继续等待 Nix 重试。

Nix 后台服务不会自动继承终端的环境变量，再为 **Live 系统**添加运行时配置：

```sh
mkdir -p /run/systemd/system/nix-daemon.service.d
cat > /run/systemd/system/nix-daemon.service.d/90-install-proxy.conf <<EOF
[Service]
Environment="http_proxy=$http_proxy"
Environment="https_proxy=$https_proxy"
Environment="HTTP_PROXY=$HTTP_PROXY"
Environment="HTTPS_PROXY=$HTTPS_PROXY"
Environment="no_proxy=$no_proxy"
Environment="NO_PROXY=$NO_PROXY"
EOF
systemctl daemon-reload
systemctl restart nix-daemon.service
```

更换代理地址时，重新设置变量并重写上述文件、重启服务。
该文件位于 Live 系统的 `/run`，重启后消失；新系统的代理在第 4 步另外设置。

### 2.3 配置安装期间的国内二进制镜像

在当前 root shell 设置 Nix 参数，后续临时工具安装、求值和 `nixos-install` 都继承它：

```sh
export NIX_CONFIG='extra-experimental-features = nix-command flakes
substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://cache.nixos.org/
connect-timeout = 15
download-attempts = 5'
nix config show substituters
curl -I --connect-timeout 10 https://mirrors.ustc.edu.cn/nix-channels/store/nix-cache-info
```

国内镜像用于获取已构建的软件包；GitHub 上的源码、flake inputs 和部分上游下载
仍可能需要代理。镜像站和代理分别解决这两类下载，不要把其中一个当作另一个的替代。
保留安装介质已有的签名公钥，不需要覆盖整个 `/etc/nix/nix.conf` 或关闭签名验证。
有关镜像地址和临时参数，见 [USTC 镜像说明](https://mirrors.ustc.edu.cn/help/nix-channels.html)。

这些环境变量只用于当前安装会话。安装后的国内镜像已经由仓库的
`modules/nixos/nix.nix` 配置，无需再手写一份通用系统配置。

### 2.4 用 cfdisk 分区

下面只适用于**已经确认可以清空的整块磁盘**。示例磁盘为 `/dev/nvme0n1`，
格式化会清除对应分区中的数据；必须替换为 `lsblk` 中核对过的实际设备。
保留已有分区时跳过分区、格式化，只挂载自己的目标分区。

```sh
cfdisk /dev/nvme0n1
```

在 cfdisk 中依次操作：

1. 空白磁盘选择 `gpt` 分区表。已有分区时先确认要保留还是删除，不要直接重建分区表。
2. 选空闲空间 → `New` → 输入 `1G`，将 `Type` 改为 `EFI System`。
3. 选剩余空闲空间 → `New` → 使用剩余容量，类型保持 `Linux filesystem`。
4. 核对分区 → `Write` → 输入 `yes` → `Quit`。

预期布局如下；以实际分区号为准：

| 分区 | 大小 | 类型 / 文件系统 | 目标系统挂载点 |
| --- | --- | --- | --- |
| `/dev/nvme0n1p1` | 1 GiB | EFI System / FAT32 | `/boot` |
| `/dev/nvme0n1p2` | 剩余空间 | Linux filesystem / ext4 | `/` |

如果是 SATA 磁盘，名称通常类似 `/dev/sda1`、`/dev/sda2`。
cfdisk 只建立分区，接下来还要创建文件系统。

### 2.5 创建文件系统并挂载

仅格式化这次新建、确认无需保留数据的分区，然后先挂载根分区，再挂载 EFI：

```sh
mkfs.fat -F 32 -n boot /dev/nvme0n1p1
mkfs.ext4 -L nixos /dev/nvme0n1p2
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/nvme0n1p1 /mnt/boot
findmnt -R /mnt
```

这个简单示例没有磁盘 swap，也没有配置休眠。需要 swap 时先完成相应设置，
再生成硬件配置。例如，在 cfdisk 中另建 `Linux swap` 类型分区后，对实际的 swap 分区
运行 `mkswap` 和 `swapon`。`findmnt -R /mnt` 应显示目标根分区与 `/mnt/boot`，
有单独 `/home` 时也必须在克隆仓库前挂载到 `/mnt/home`。

## 3. 将配置仓库放进目标系统

保留第 2 步的代理和 `NIX_CONFIG` 环境变量，进入带 Git、age 和 SOPS 的 shell，
然后直接在目标系统的固定路径创建目录并克隆仓库：

```sh
nix shell nixpkgs#git nixpkgs#age nixpkgs#sops -c bash
mkdir -p /mnt/home/spreadzhao/workspaces
git clone --branch nixos https://github.com/SpreadZhao/spreadconfig.git \
  /mnt/home/spreadzhao/workspaces/spreadconfig
cd /mnt/home/spreadzhao/workspaces/spreadconfig
```

如果远端是私有仓库，先通过已有凭据获取仓库，或从可信设备复制完整副本到同一位置。
不要把 token 放进 Git URL。此时还没有由 SOPS 配好的 GitHub CLI 登录。

安装环境中的 `/mnt/home/spreadzhao/workspaces/spreadconfig`，重启后就是
`/home/spreadzhao/workspaces/spreadconfig`。大量应用配置和 `~/scripts` 链接依赖
这个可编辑副本，不能只克隆到安装 U 盘或临时目录；以后也不要直接移动或删除它。
其他工具、skills 和软件包由 flake inputs 获取，无需逐个克隆。

## 4. 选择主机，生成这台电脑的硬件配置

已有主机声明：

| 名称 | 对应设备 |
| --- | --- |
| `desktop1` | Intel CPU、GTX 1650 独显的现有台式机 |
| `thinkbook` | AMD CPU / AMD 集显的现有 ThinkBook |
| `zephyrus-m16` | Intel / NVIDIA 混合显卡的现有 ASUS Zephyrus M16 |

只有重装对应设备才直接复用它的声明。**CPU 品牌相同不代表硬件配置相同**，
另一台电脑先按文末“新增主机”建立自己的 host，再回到这里。

将变量改为实际目标主机名；后面始终在同一个 shell 使用它：

```sh
target_host='zephyrus-m16'
test -f "hosts/$target_host/host.nix"
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
  "hosts/$target_host/hardware-configuration.nix"
```

即使重装旧电脑，重新分区后也要重新生成。检查生成文件中的根分区、EFI、swap、
UUID 和加密设备是否对应这次挂载的磁盘；保留仓库的 `configuration.nix` 及其
模块导入，不要用安装器生成的通用 `configuration.nix` 覆盖它。

还要检查 `host.nix`、`nixos/` 中的显卡驱动、PRIME PCI 地址和机型专用服务，
以及 `home/niri/host.kdl` 中的显示器配置。

### 配好第一次启动后的网络

Live 环境中的代理配置不会自动迁移到目标系统。共享配置默认使用
`http://127.0.0.1:7897`，并安装 Clash Verge；新电脑仍需要导入订阅/配置并启动代理，
才会在本机提供这个端口。首次启动前选择一种方式：

- **继续使用局域网代理**：保留 `nixos/profile.nix` 中的 `proxy.enable = true;`
  （未指定时默认就是 true）。创建目标主机的 `nixos/install-proxy.nix`，内容如下，
  把地址换成实际代理：

  ```nix
  { lib, ... }:
  {
    networking.proxy.default = lib.mkForce "http://192.168.1.10:7897";
  }
  ```

  再向该主机 `configuration.nix` 已有的 `imports` 列表加入
  `./nixos/install-proxy.nix`，保留其他导入。此后系统服务和登录终端都使用这个代理。
  本地 Clash Verge 配置好后，删除这一项导入并手动重建，恢复默认本机代理地址。
- **直接联网**：在目标主机的 `nixos/profile.nix` 属性集中加入
  `proxy.enable = false;`。这也会关闭此配置管理的代理应用安装；以后需要时改回 true
  并手动重建。
- **本机代理已准备好**：保持默认地址，确认新系统能启动代理且监听 `7897`。

这一步只决定安装后的网络，不改变当前 Live 终端正在使用的代理。

## 5. 在安装前初始化 SOPS

仍在配置仓库根目录运行：

```sh
bash ./scripts/sops-key init --root /mnt
stat -c '%U:%G %a %n' /mnt/var/lib/sops-nix/key.txt
```

在终端提示中输入 `shared-age-key.age` 的解锁口令。脚本验证该身份能解密当前
`secrets/secrets.yaml`，然后安装到目标系统。检查结果应为 `root:root 600`。
重复执行会验证已有身份；如果已有密钥不匹配，脚本停止，不会覆盖它。

这一步为首次安装准备系统凭据，并没有导入 GPG。不要把明文 age 身份复制进
配置仓库。使用临时根文件系统时，需要持久化 `/var/lib/sops-nix`。
细节见 [SOPS 说明](sops.md)。

## 6. 检查配置并安装整个系统

先求值，确认主机配置可以生成系统构建：

```sh
nix eval --raw --no-write-lock-file \
  "path:$PWD#nixosConfigurations.${target_host}.config.system.build.toplevel.drvPath"
```

这里使用 `path:`，使刚新增、尚未被 Git 跟踪的主机文件也参与求值。
首次安装沿用仓库的 `flake.lock`，不需要先执行 `nix flake update`。

然后直接指定 spreadconfig 的 flake 安装；这一步会下载/构建完整系统，
并包含 Home Manager 用户环境，不需要先安装一套通用桌面系统：

```sh
nixos-install --root /mnt --flake "path:$PWD#$target_host"
```

该命令继承当前终端的代理和镜像配置。若当前 shell 的 `NIX_CONFIG` 丢失，
先重新执行第 2.3 步；也可以在本次安装命令中明确指定镜像：

```sh
nixos-install --root /mnt --flake "path:$PWD#$target_host" \
  --option substituters 'https://mirrors.ustc.edu.cn/nix-channels/store https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://cache.nixos.org/'
```

若下载失败或某个镜像长时间无响应，可按 `Ctrl+C` 停止本次安装，修正代理或镜像后
在同一挂载布局和仓库路径下重跑安装命令，已有可用的 store 内容会复用。
不是每一个正在传输的文件都能断点续传；重试无需再次分区、格式化或重新生成密钥。
某个镜像持续不可用时，把它从 `substituters` 移除；代理可用时也可以只保留
`https://cache.nixos.org/`。完整安装成功前不要重启。

安装末尾按提示设置 root 密码。`spreadzhao` 的登录密码由 SOPS 中的
`spreadzhao-password-hash` 提供，使用准备阶段确认过的对应密码。
无需另外安装或执行 `home-manager switch`。

安装成功后，把刚才由 root 克隆的工作目录交给目标用户：

```sh
nixos-enter --root /mnt -c \
  'chown spreadzhao:users /home/spreadzhao && chown -R spreadzhao:users /home/spreadzhao/workspaces'
reboot
```

重启时移除安装 U 盘。到这里，即使还没有 Password Store，系统也可以启动；
`pass-secret-service` 会因缺少 `.gpg-id` 跳过启动，Chromium 会跳过私有书签生成。

## 7. 首次登录，检查 SOPS 和 GitHub 登录

以下所有用户操作都以 **`spreadzhao` 普通用户**执行；只在命令写明时使用 `sudo`。
进入图形会话后打开终端：

```sh
cd ~/workspaces/spreadconfig
hostname
test -f flake.nix && echo '配置仓库路径正常'
sudo env SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt \
  sops decrypt secrets/secrets.yaml > /dev/null
gh auth status
```

解密检查不会输出凭据。GitHub CLI 应使用系统生成的登录，无需再次 `gh auth login`。
若登录检查失败，先检查 SOPS 激活、共享 token 和网络；环境中的 `GH_TOKEN`、
`GITHUB_TOKEN` 或自定义 `GH_CONFIG_DIR` 也可能覆盖受管配置。

## 8. 克隆 Password Store，恢复 GPG 身份

```sh
git clone https://github.com/SpreadZhao/password-store.git ~/.password-store
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
cat ~/.password-store/.gpg-id
gpg --show-keys --with-fingerprint ~/.password-store/backup/gpg_pub_backup.pgp
gpg --show-keys --with-fingerprint ~/.password-store/backup/gpg_bakcup.pgp
```

核对两个备份的主钥指纹一致，并与原电脑或可信备份记录相符，身份也应匹配
`.gpg-id`。`gpg_bakcup.pgp` 是现有私钥备份的实际文件名，拼写不要改成 `backup`。

```sh
gpg --import ~/.password-store/backup/gpg_pub_backup.pgp
gpg --import ~/.password-store/backup/gpg_bakcup.pgp
gpg --list-secret-keys --keyid-format long
```

将下面占位符替换为刚核对过的、无空格的完整主钥指纹，只为自己持有的身份恢复信任：

```sh
printf '%s:6:\n' '<已核对的主钥完整指纹>' | gpg --import-ownertrust
pass ls
pass show '<从 pass ls 中选取的现有条目路径，不含 .gpg>' > /dev/null
```

最后一条用于验证解密；需要时在本机弹窗输入 GPG 私钥口令，不会打印密码。
这些 GPG 命令不要加 `sudo`，否则会把密钥导入 root 的密钥环。
如果缺少可用私钥，先从原设备恢复；不要为现有密码库生成替代密钥或重新 `pass init`。

**私钥导入后 pass 就可以使用，不需要等下一次 rebuild。**
完整说明和故障检查见 [Password Store 接入](password-store.md)。

## 9. 启动 Secret Service，再构建并手动激活

在已登录的用户会话中启动服务：

```sh
systemctl --user restart pass-secret-service.service
systemctl --user is-active pass-secret-service.service
busctl --user status org.freedesktop.secrets
```

服务应显示 `active`。仓库若沿用 `secret_service/` 的 Git 忽略规则，clone 不会
恢复旧电脑的这些应用凭据；需要迁移它们时，另行恢复该目录的加密备份和元数据，
不能把 Git clone 当成完整的应用凭据迁移。

检查 `~/.config/qutebrowser/quickmarks`。它应链接到
`~/.password-store/qutebrowser/qutebrowser_quickmarks`。若已被浏览器写成普通文件，
先退出 qutebrowser，并按 [Password Store 文档](password-store.md#接入-qutebrowser-quickmarks)
备份这个文件后再激活，保留私有仓库中的收藏。

然后在仓库根目录执行。重启后重新设置目标主机名；纯构建和应用分开：

```sh
cd ~/workspaces/spreadconfig
target_host=$(hostname -s)
test -f "hosts/$target_host/host.nix"
sudo nixos-rebuild build --flake "path:$PWD#$target_host"
```

构建成功后，由你本人手动执行下面的激活命令：

```sh
sudo nixos-rebuild switch --flake "path:$PWD#$target_host"
```

这次激活会补齐依赖私有仓库的集成，尤其是 Chromium managed bookmarks。
只有 `build` 不会刷新书签。没有 quickmarks 源文件时继续跳过生成；有文件时可检查：

```sh
test -r ~/.password-store/qutebrowser/qutebrowser_quickmarks && \
  test -f /etc/chromium/policies/managed/qutebrowser-bookmarks.json && \
  echo 'Chromium 书签策略已生成'
```

## 10. 日常使用与维护

系统已经具备完整环境后，再按需处理 fcitx5、代理订阅、浏览器登录等应用设置。
整理并提交这台机器的 host / 硬件配置变化，方便下次恢复；GPG 密钥环和明文
SOPS 身份不属于配置仓库。Password Store 用它自己的 Git push/pull 流程同步。

- 保持 `/home/spreadzhao/workspaces/spreadconfig` 原位，供应用配置和脚本链接使用。
- 一般配置改动：先 `nixos-rebuild build` 检查，再手动 `switch`。
- 更新 inputs 并准备下一次启动的系统：`~/scripts/nix/nix_update boot`，成功后手动重启。
- `sns` / `sns_until` 不带参数时默认 `switch`；需要该效果时由用户手动执行。
  AI 代理遵守仓库规则，不执行 `switch`，也不调用隐式执行它的脚本。

## 补充：电脑已经安装了 NixOS

不需要重新分区或 `nixos-install`，沿用同样的先后关系：

1. 用 `spreadzhao` 用户把仓库放到 `~/workspaces/spreadconfig`。
2. 选择或新增 host，用当前机器生成的硬件配置替换该 host 的硬件文件。
   在已安装系统执行 `sudo nixos-generate-config`，使用 `/etc/nixos/hardware-configuration.nix`，
   不要使用 `--root /mnt`。
3. 在仓库根目录用 `nix shell nixpkgs#age nixpkgs#sops -c bash ./scripts/sops-key init`
   初始化当前系统的 `/var/lib/sops-nix/key.txt`；必要时先临时启用 flakes。
4. 显式指定目标 host 执行 `build`，然后手动 `switch`，先获得共享系统和用户环境。
   首次迁移时当前 hostname 可能不同，不能直接用 `hostname -s` 选择配置：

   ```sh
   cd ~/workspaces/spreadconfig
   target_host='zephyrus-m16' # 改成准备好的目标 host。
   sudo nixos-rebuild build --flake "path:$PWD#$target_host"
   ```

   检查成功后，手动执行：

   ```sh
   sudo nixos-rebuild switch --flake "path:$PWD#$target_host"
   ```

5. 按第 7～9 步检查凭据、克隆 Password Store、导入 GPG，再构建并手动激活一次。

从其他桌面配置迁移时，Home Manager 若报告已有普通文件冲突，应先备份对应文件，
再让配置接管；尤其不要覆盖已有的浏览器 quickmarks。

## 补充：新增主机

flake 自动发现 `hosts/<名称>/host.nix`，不必另改主机列表。为新设备建立独立目录，
不要覆盖另一台电脑的 host。以下是 **Intel 集显笔记本**的最小声明示例，名称为
`my-laptop`；AMD、NVIDIA 或混合显卡应按实际设备调整声明和驱动。

先在配置仓库根目录准备目录，再创建下面列出的文件：

```sh
mkdir -p hosts/my-laptop/nixos hosts/my-laptop/home/niri
```

`hosts/my-laptop/host.nix`：

```nix
{
  system = "x86_64-linux";
  formFactor = "laptop";
  cpu.vendor = "intel";
  gpu.devices = [
    { vendor = "intel"; kind = "integrated"; }
  ];
  capabilities = {
    battery = true;
    backlight = true;
    bluetooth = null;
  };
  profile = {
    nixos = import ./nixos/profile.nix;
    home = import ./home/profile.nix;
  };
  modules = {
    nixos = [ ./configuration.nix ];
    home = [ ./home.nix ];
  };
}
```

`hosts/my-laptop/configuration.nix`：

```nix
{ host, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = host.name;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
```

`hosts/my-laptop/home.nix`：

```nix
{ ... }:
{
  spreadconfig.apps.niri.hostConfig = "hosts/my-laptop/home/niri/host.kdl";
}
```

另外创建 `nixos/profile.nix`（初始可为 `{ proxy.enable = false; }`）、
`home/profile.nix`（初始可为 `{ }`）、`home/niri/host.kdl`（初始可为空，
后续按实际输出接口添加显示器设置）。`hardware-configuration.nix` 在第 4 步
从新机器生成；将 `target_host` 设成 `my-laptop` 后继续流程。

CPU/GPU 声明只供共享模块选择策略，不会自动写好所有机型的驱动配置。
例如 NVIDIA 驱动和 PRIME 地址应在主机 NixOS 模块中配置，不能照抄 M16 的地址。
更详细的组织方式见 [主机与应用布局](application-layout.md)。
