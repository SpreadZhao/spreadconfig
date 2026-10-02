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

### 首次初始化

先按 [SOPS 初始化说明](../../docs/sops.md) 同步完整仓库，包括 `.sops.yaml`、`secrets/secrets.yaml` 和 `secrets/shared-age-key.age`。然后在本机仓库根目录执行：

```bash
./scripts/sops-key init
```

输入共享私钥备份的口令。脚本验证解密成功后，将私钥安装到 `/var/lib/sops-nix/key.txt`（root:root、0600）；之后启动和 rebuild 不再询问口令。已有有效私钥时重复执行不会要求口令，也不会覆盖它。

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
共享私钥的加密备份保存在仓库；请保管好解锁口令，不要提交本地明文私钥。
