# Nix-on-Droid

This is the Android host for the main flake.

The host-specific layer only configures Nix-on-Droid/Android integration. The interactive user
environment is intentionally shared with the rest of this repository through Home Manager:

- `home/nix-on-droid.nix` is the Android-specific lightweight Home Manager entrypoint.
- It reuses the repository's shared Git, Nushell, Helix, and Starship modules.
- Do not add a second copy of Git/editor/shell configuration under this host.

## Activate

From an existing Nix-on-Droid installation:

```sh
cd ~/nix-config
nix-on-droid switch --flake .#nix-on-droid
```

Or use the repository's Just recipe:

```sh
just droid-switch
```

Other useful commands:

```sh
just droid-build
just droid-generations
just droid-rollback
just droid-up
```

Nix-on-Droid flake configurations are activated with `nix-on-droid switch --flake <flake>#<name>`.
The Android package set remains separate from the main NixOS package set, while Home Manager is
shared so the user-facing configuration does not fork.
