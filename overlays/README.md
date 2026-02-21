# Overlays

Overlays for both NixOS and Nix-Darwin.

If you don't know much about overlays, it is recommended to learn the function and usage of overlays
through [Overlays - NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/nixpkgs/overlays).

## Current Structure

```
overlays/
├── README.md
├── default.nix          # Entrypoint for all overlays
├── fcitx5/              # Chinese input method (rime data lives in a separate repo)
│   ├── README.md
│   ├── default.nix      # fcitx5 overlay definition
├   └── rime-data-custom/ # Custom rime data
├       └── share/
├           └── rime-data/
└── openldap.nix
```

## Components

### 1. `default.nix`

The entrypoint of overlays, it execute and import all overlay files in the current directory with
the given args.

### 2. `fcitx5`

fcitx5's overlay, wires up my customized Chinese input method data for the `fcitx5-rime` package.

The Rime data itself (dictionaries, schemas, Lua scripts) lives in its own repository,
[ENOA-REIAH-UION/rime-data](https://github.com/ENOA-REIAH-UION/rime-data), and is consumed here as
the `rime-data` flake input. This overlay provides:

- `rimeDataPkgs` for `fcitx5-rime` — the nixpkgs default `rime-data` plus the external `rime-data`
  input.
- `rime-data-custom` — an alias of the external input, for reuse by other Rime frontends.

> [!NOTE] The data can also be configured locally — a directory in this repo passed straight to
> `rimeDataPkgs` (what the old `overlays/fcitx5/rime-data-custom/` did). It was split into a
> separate repository because the scheme is very large and needs frequent, flexible changes.
