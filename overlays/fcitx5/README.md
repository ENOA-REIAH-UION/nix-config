# fcitx5 - IME (Rime)

Custom Chinese input method data for Linux (`fcitx5-rime`).

## Data source

The Rime data (dictionaries, schemas, Lua scripts) lives in its own repository:
[ENOA-REIAH-UION/rime-data](https://github.com/ENOA-REIAH-UION/rime-data).

It is pulled in as the `rime-data` flake input (see [flake.nix](/flake.nix)) and fed to
`fcitx5-rime` via `rimeDataPkgs` in [default.nix](./default.nix).

> [!NOTE] The data can also be configured locally — a directory in this repo passed straight to
> `rimeDataPkgs` (what the old `rime-data-custom/` did). It was split into a separate repository
> because the scheme is very large and needs frequent, flexible changes.

## Linux (fcitx5-rime)

1. `~/.config/fcitx5/profile` is linked to
   [home/linux/gui/base/fcitx5/profile](/home/linux/gui/base/fcitx5/profile), which hardcode rime as
   the default input method, so you do not need to use fcitx-configtool to adjust fcitx5's input
   method.

## Docs about fcitx5

- [Fcitx5 - Arch Linux Wiki](https://wiki.archlinux.org/title/Fcitx5)
- [Fcitx5 - Official Wiki](https://fcitx-im.org/wiki/Fcitx_5/zh-cn)
