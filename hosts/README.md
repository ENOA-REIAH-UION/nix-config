# Hosts

This directory contains host-specific NixOS and Nix-on-Droid configurations.

## Current Host Inventory

### `idols-ai`

The main NixOS workstation configuration. The flake exposes it as
`nixosConfigurations.ai-niri`.

### `k8s`

Kubernetes infrastructure:

- KubeVirt nodes: `kubevirt-shoryu`, `kubevirt-shushou`, `kubevirt-youko`
- K3s production: three masters and three workers
- K3s testing: three masters

### `nix-on-droid`

A lightweight Android configuration exposed as
`nixOnDroidConfigurations.nix-on-droid`. It currently focuses on TUI tooling,
with Nushell, Helix, Git, and a small set of command-line utilities.

## Adding a Host

1. Create the host directory under `hosts/`.
2. Add the host to the appropriate section of the root `flake.nix`.
3. Add a Home Manager module under `home/hosts/linux/` if needed.
4. Update `vars/networking.nix` only when the host needs a static local-network address.

The root `flake.nix` is intentionally the single place where host outputs are registered; there is
no separate `outputs/` tree.

## References

- `idols-ai/` — workstation configuration
- `k8s/` — Kubernetes/KubeVirt host configurations
- `nix-on-droid/` — Android TUI configuration
