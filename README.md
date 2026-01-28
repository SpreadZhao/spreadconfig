files in ./secrets/

- gh_token: github cli token `pass show github/token`
- passwd: login password `pass show sudo`
- qutebrowser_quickmarks: quickmarks of qutebrowser, can be an empty file

[make a soft link](https://nixos-and-flakes.thiscute.world/zh/nixos-with-flakes/other-useful-tips#git-manage-nixos-config):

```bash
sudo ln -s /path/to/spreadconfig /etc/nixos
```
