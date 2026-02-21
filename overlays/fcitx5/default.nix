# 为了不使用默认的 rime-data，改用我自定义的方案数据，这里需要 override
# 参考 https://github.com/NixOS/nixpkgs/blob/e4246ae1e7f78b7087dce9c9da10d28d3725025f/pkgs/tools/inputmethods/fcitx5/fcitx5-rime.nix
_:
(_: super: {
  # 不要覆盖默认内置配置，许多方案依赖基础配置(https://github.com/rime/rime-prelude)
  # rime-data = ./rime-data-enoa;
  fcitx5-rime = super.fcitx5-rime.override {
    rimeDataPkgs = [
      super.rime-data
      ./rime-data-enoa
    ]; };

  # used by macOS Squirrel
  flypy-squirrel = ./rime-data-enoa;
})
