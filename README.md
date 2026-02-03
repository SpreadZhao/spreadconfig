## Things to do after install

### files in `./secrets/`

- gh_token: github cli token `pass show github/token`
- passwd: login password `pass show sudo`
- qutebrowser_quickmarks: quickmarks of qutebrowser, can be an empty file

### make a soft link

[make a soft link](https://nixos-and-flakes.thiscute.world/zh/nixos-with-flakes/other-useful-tips#git-manage-nixos-config):

```bash
sudo ln -s /path/to/spreadconfig /etc/nixos
```

### fcitx5

Now that I have not already make fcitx5 config to work, so stuff like theme,addons,classic-ui,etc. should be configured manually.

### davfs

Write your secrets to `~/.davfs/secrets`, ref: [davfs2 - ArchWiki](https://wiki.archlinux.org/title/Davfs2#Storing_credentials)
