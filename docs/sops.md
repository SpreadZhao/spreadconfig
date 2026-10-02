# SOPS 共享身份

所有 host 使用同一个 age 公钥加密 `secrets/secrets.yaml`。密码加密的私钥文件为 `secrets/shared-age-key.age`，可以提交到仓库。每台机器只在初始化时输入一次解锁口令，随后通过 `/var/lib/sops-nix/key.txt` 自动解密；该文件在仓库和 Nix store 外，归 root 所有，权限为 0600。

## 初始化前准备

同步完整仓库，确保包含以下三个文件：

- `.sops.yaml`
- `secrets/secrets.yaml`
- `secrets/shared-age-key.age`

所有机器复用这份加密私钥和同一个解锁口令。初始化不会生成密钥、设置新口令或修改仓库中的凭据。

## 初始化其他机器

在已安装系统的仓库根目录执行：

```bash
./scripts/sops-key init
```

输入解锁口令，脚本验证私钥能解密当前 secrets 后再安装。重复运行时验证已存在的私钥，不重复要求口令；已有不匹配的私钥时停止，不覆盖。

全新安装、目标根分区已挂载到 `/mnt` 时，在 `nixos-install` 前执行：

```bash
nix shell nixpkgs#age nixpkgs#sops -c bash ./scripts/sops-key init --root /mnt
```

私钥会写到目标系统的 `/mnt/var/lib/sops-nix/key.txt`。以后正常启动和 rebuild 无需输入解锁口令。保留 `/var/lib/sops-nix`；若使用临时根文件系统，需要将此目录持久化。

## 编辑凭据

在已初始化的机器上验证解密（不输出凭据）：

```bash
sudo env SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt sops decrypt secrets/secrets.yaml > /dev/null
```

编辑时使用同一个本地身份：

```bash
sudo env SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt sops edit secrets/secrets.yaml
```

解锁口令只保护仓库中的私钥副本，本地安装的私钥是明文。所有机器持有相同身份；一台机器的私钥泄露会影响全部共享凭据。初始化不会轮换 token 或账户密码。

参考：[age 密码加密](https://github.com/FiloSottile/age#passphrase-encryption)、[sops-nix 密钥配置](https://github.com/Mic92/sops-nix)。
