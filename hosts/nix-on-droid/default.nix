{ pkgs, myvars, mylib, pkgs-master, ... }:

{
  # Nix-on-Droid is the Android host layer. The user environment itself is
  # intentionally shared with the main repository through Home Manager below.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    extraSpecialArgs = {
      inherit myvars mylib pkgs-master;
    };
    config = {
      imports = [
        ../../home/nix-on-droid.nix
       ];
    };
  };

  imports = [ ./droid ];

  environment.packages = with pkgs; [
    curl
    just
    less
    openssh
    ripgrep
    unzip
    wget
    which
    zip
		gnused

    patchelf
    autoPatchelfHook
  ];

  environment.etcBackupExtension = ".bak";

  android-integration = {
    termux-open.enable = true;
    termux-open-url.enable = true;
    termux-setup-storage.enable = true;
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "24.05";

  # 临时修复：proot-static 损坏
  #
  # 最初使用 prerelease-25.11 时遇到 proot-static 损坏问题，通过从旧世代
  # 复制可用的 proot-static 覆盖 .proot-static.new 解决。
  #
  # 切换至 nixpkgs-unstable（> 25.11）后出现 PTY 错误：
  #   error: getting pseudoterminal attributes: Permission denied
  #   error: reading a line: Input/output error
  #
  # 该问题会导致 Nushell、Emacs 等依赖 TTY 的软件无法正常运行。
  # 当时相关 PR 尚未合并，解决方法仅仅是将 proot-static 更新为 2026-6-20
  # 而 prerelease-25.11 使用的 proot-static 已为 6-21，
  # 因此认为该 PR 仅用于修复此前的 proot-static 损坏问题。
  #
  # PR 合并后，我开始感到怀疑，没想到使用 6-20 的 proot-static
  #
  # 不仅不需要以下丑陋的配置，更是解决了 TTY 的问题 (属于是判断失误白折腾了....)
  #
  # build.activation.zz_unfuck_proot = ''
  #   echo "overwriting proot-static.new with old (and working) proot executable"
  #   cp -v /data/data/com.termux.nix/files/usr/bin/proot-static \
  #     /data/data/com.termux.nix/files/usr/bin/.proot-static.new
  # '';

  # Hack: 将 bash 映射为 sh，使 Claude CLI 等依赖 POSIX shell 的软件在非 FHS 环境中能够正常找到并调用 shell
  build.activation.zz_unfuck_shell = ''
    if [ ! -e /data/data/com.termux.nix/files/usr/bin/bash ]; then
      echo "creating bash -> sh symlink for Claude CLI"
      ln -sf /data/data/com.termux.nix/files/usr/bin/sh /data/data/com.termux.nix/files/usr/bin/bash
    fi
  '';

  # extra-keys 等设置项非 termux-app(nix-on-droid-app) 主分支
  build.activation.termux-extra-keys = ''
    mkdir -p "$HOME/.termux"
    cat > "$HOME/.termux/termux.properties" <<'EOF'
extra-keys = [['ESC','TAB','CTRL','ALT','LEFT','UP','DOWN','RIGHT']]
extra-keys-button-text-color=#FFFFFF
extra-keys-button-active-text-color=#FF5555
extra-keys-button-background-color=#99000000
extra-keys-button-active-background-color=#444444
extra-keys-button-area-background-color=#00000000
extra-keys-button-gap=8
EOF
  '';

  build.activation.termux-color = ''
    mkdir -p "$HOME/.termux"
    cat > "$HOME/.termux/colors.properties" <<'EOF'
background=#23232F
cursor=#FFFFFF
foreground=#FFFFFF
# background-image=
background-alpha=0.8
EOF
  '';

}
