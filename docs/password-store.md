# password-store 本机接入

除 `~/workspaces/spreadconfig` 本身外，共享配置唯一需要预先克隆的项目是
`~/.password-store`。GPG 和 SOPS age 是不同的身份：SOPS 解密系统凭据，
GPG 解密 pass 条目。其他工具和 skills 由 flake 获取，不需要本地项目副本。

## 恢复 GPG 身份

1. 将私有密码仓库克隆到 `~/.password-store`，保留原有 `.gpg-id`。
2. 检查备份中的公钥身份和指纹，确认匹配 `.gpg-id`：

   ```sh
   cat ~/.password-store/.gpg-id
   gpg --with-colons --show-keys ~/.password-store/backup/gpg_pub_backup.pgp
   gpg --with-colons --show-keys ~/.password-store/backup/gpg_bakcup.pgp
   ```

3. 导入同一身份的公私钥备份；`gpg_bakcup.pgp` 是现有仓库中的文件名：

   ```sh
   gpg --import ~/.password-store/backup/gpg_pub_backup.pgp
   gpg --import ~/.password-store/backup/gpg_bakcup.pgp
   gpg --list-secret-keys --keyid-format long
   ```

   GPG agent 使用 Home Manager 配置的 `pinentry-wayprompt`，需要口令时在本机
   窗口输入。私钥保存在权限为 0700 的 `~/.gnupg` 中。若备份没有可用私钥，
   从原机恢复正确备份，不为已有密码库生成新密钥或重新运行 `pass init`。

4. 对自己持有的身份恢复 ultimate 信任；将下面的占位符替换为已核对的主钥指纹：

   ```sh
   printf '%s:6:\n' '<主钥完整指纹>' | gpg --import-ownertrust
   ```

5. 选一个已有条目验证解密，输出丢弃：

   ```sh
   pass show '<现有条目名>' > /dev/null
   ```

私钥导入和信任恢复属于本机的一次性操作，不在 Nix 激活时自动执行。
密码条目、私钥和收藏内容都留在 Nix store 和配置仓库之外。

## 启动 secrets 服务

共享配置已经安装 pass，并将 `PASSWORD_STORE_DIR`、pass-secret-service 的
`storePath` 指向 `~/.password-store`。GPG agent 通过 socket 按需启动；
仅服务显示 inactive 不代表故障。

pass-secret-service 在 `.gpg-id` 尚不存在时跳过启动。克隆仓库并恢复密钥后，
重新启动已安装的用户服务：

```sh
systemctl --user restart pass-secret-service.service
systemctl --user is-active pass-secret-service.service
busctl --user status org.freedesktop.secrets
```

密码菜单沿用 `~/scripts/util/bin/pmenu` 和 `pmenu_last`。仓库同步仍使用原有
Git push/pull 流程；系统激活不克隆、同步或重新加密密码条目。

## 接入 qutebrowser quickmarks

各主机复用共享的 qutebrowser 配置、主题和快捷键，并通过主机配置调整字体及缩放。
Home Manager 将 `~/.config/qutebrowser/quickmarks` 链接到
`~/.password-store/qutebrowser/qutebrowser_quickmarks`。

若首次启动 qutebrowser 后已有普通 quickmarks 文件，先退出浏览器，将该文件
移动到带时间戳的备份，再由 Home Manager 接管链接。即使本机文件为空也保留备份，
不覆盖私有仓库里的收藏。已有正确链接无需处理。

构建只包含路径和链接，不读取收藏数据。下一次 `switch` 或启动激活时，
NixOS 会从私有文件生成 Chromium 的 managed bookmarks；单独构建不会刷新它。
