# desktop1

从旧 `nixos_desktop1` 分支迁入 `nixos` 的 Intel + NVIDIA 台式机。
之后统一使用 `nixos` 分支和 `#desktop1`，不再维护独立分支。

## 保留与复用

- 保留旧机的主机名 `desktop1`、Intel KVM、启动所需模块和磁盘信息：
  - `/`：ext4，UUID `9663f1c4-7588-42e8-898a-501a39ead627`。
  - `/boot`：vfat，UUID `FC69-4BB9`，保留原挂载选项。
  - 没有配置 swap。
- 保留原 NVIDIA 直连方案：开放内核模块、稳定版驱动、modesetting；启用 64/32 位图形支持。
- 不导入 Zephyrus 的 ASUS 硬件模块、PRIME 总线地址、Dynamic Boost、细粒度省电或电池服务。
- 系统和 Home Manager 使用当前全部公共模块，Niri、Waybar、字体和应用配置回退到 `spreadconfig/{config,scripts}/default`。
- btop 使用已有 NVIDIA 包装和监控设置。`sns`、`sns_until` 指向 `#desktop1`。
- 沿用原机与公共配置一致的 `system.stateVersion`、`home.stateVersion = "25.11"`，不随软件升级修改。
- `flake.lock` 沿用当前 `nixos`，不从旧分支复制软件、旧主题或依赖版本。

## 使用共享凭据

`desktop1` 与其他机器共用 `secrets/secrets.yaml`，通过公共模块 `modules/nixos/secrets.nix` 加载。
其中包含 GitHub token、用户密码哈希和 TextBridge token，不再生成独立凭据。
已有账户的登录密码不会被重置；修改当前账户密码使用 `passwd`。

本机通过 `/etc/ssh/ssh_host_ed25519_key` 解密。确认其公钥对应根目录 `.sops.yaml` 的 `host_desktop1`：

```bash
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

### 首次授权

只在 `.sops.yaml` 添加公钥还不够，必须使用已有授权身份重新封装共享文件的数据密钥。
在持有管理员 age 私钥的电脑上，从包含最新 `.sops.yaml` 的仓库根目录执行（替换私钥路径）：

```bash
SOPS_AGE_KEY_FILE=/path/to/admin-keys.txt sops updatekeys secrets/secrets.yaml
```

如果使用已授权旧机器的 SSH host key，可在那台机器上执行：

```bash
sudo env SOPS_AGE_SSH_PRIVATE_KEY_FILE=/etc/ssh/ssh_host_ed25519_key sops updatekeys secrets/secrets.yaml
```

检查变更并同步根目录 `.sops.yaml` 和更新后的 `secrets/secrets.yaml` 到 desktop1。
`updatekeys` 保留原有凭据值，并按规则保留其他机器的解密授权。
不要用 desktop1 的新凭据覆盖共享文件；desktop1 自己的密钥无法为尚未授权给它的旧密文添加权限。

### 重建前验证

在 desktop1 仓库根目录执行，确认解密成功（不输出明文）：

```bash
sudo env SOPS_AGE_SSH_PRIVATE_KEY_FILE=/etc/ssh/ssh_host_ed25519_key sops decrypt secrets/secrets.yaml > /dev/null
```

验证成功后再重建：

```bash
findmnt /boot
lsblk -f
sudo nixos-rebuild boot --flake .#desktop1
```

确认 `/` 和 `/boot` 仍匹配上面的 UUID，且 `/boot` 已挂载。
如果是重新分区安装的机器，先用真实的 `nixos-generate-config` 结果替换 `hosts/desktop1/hardware-configuration.nix`；不要沿用旧磁盘 UUID。
`boot` 成功后重启，检查 `nvidia-smi`、`niri msg outputs`、网络和登录。

后续日常更新使用 `~/scripts/nix/sns_until switch`，内核等启动变更使用 `~/scripts/nix/sns_until boot`。
请备份本机 SSH 私钥，且不要将其提交到仓库。
