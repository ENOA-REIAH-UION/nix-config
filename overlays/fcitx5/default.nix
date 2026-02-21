# 覆盖 nixpkgs 默认的 Rime 数据，使用自定义方案数据。
# 参考： https://github.com/NixOS/nixpkgs/blob/e4246ae1e7f78b7087dce9c9da10d28d3725025f/pkgs/tools/inputmethods/fcitx5/fcitx5-rime.nix
inputs:
(final: prev: {
  fcitx5-rime = prev.fcitx5-rime.override {
    rimeDataPkgs = [
      # nixpkgs 默认的 `rime-data` 包含 `rime-prelude` 等基础配置，
      # 部分 Rime 方案可能依赖其中的文件（例如 `symbols.yaml`）。
      #
      # 在 nixpkgs commit 4b2b576b0efd28e9f8535119760cbd8dc9bac5bd 之前，
      # 缺少 `default.yaml` 甚至可能导致 fcitx5-rime 无法正常工作。
      #
      # 若自定义方案依赖这些基础配置，可以同时引入 `prev.rime-data` 和自定义数据，
      # 或是在自定义数据中补全所依赖的基础配置。
      #
      prev.rime-data

      # 自定义 Rime 数据来自独立仓库，见 flake.nix 的 `rime-data` input。
      # 也可以直接把数据放在本仓库的 rime-data-custom目录里，但由于方案数据很大、且需要频繁灵活地改动，已独立成单独的仓库
      inputs.rime-data

      final.rime-data-custom
    ];
  };

  # 导出自定义 Rime 数据，供不同平台和 Rime 前端复用。
  # 例如 fcitx5-rime 和 macOS Squirrel。
  rime-data-custom = ./rime-data-custom;
})
