{ pkgs, ... }:

# NOTE:
# nixpkgs 中部分 Android SDK / NDK 工具链目前缺少可直接使用的
# aarch64-linux 构建，因此暂时使用第三方提供的 aarch64-linux-musl
# Release，并由 Nix 负责统一组装。
#
# 当前部分依赖来自 HomuHomu833 / liuzhiyong 的第三方 Release。
# 这些 Release 不保证长期可用：
#   - 上游可能重新上传或替换已有 artifact；
#   - liuzhiyong 不保证永久保留历史 Release。
#
# 因此，即使 Nix 配置本身保持不变，未来仍可能因上游 artifact
# 被替换或删除而导致 sha256 校验失败或下载 404。
#
# 这里固定的 hash 只能保证下载内容与预期内容一致，
# 无法保证上游 artifact 本身永久存在。
#
# TODO:
# 逐步自行构建 LLVM / Clang / Android NDK 工具链，固定源码、
# patch 及构建依赖，并最终移除对第三方预编译 Release 的依赖，
# 以获得真正可复现、可维护且长期稳定的 aarch64 Android toolchain。

let
  ndkVersion = "28.2.13676358";

    androidSdk = pkgs.runCommand "android-sdk" {
    nativeBuildInputs = [ pkgs.xz pkgs.unzip ];
  } ''
    mkdir -p $out

    tar -xf ${pkgs.fetchurl {
      url = "https://github.com/HomuHomu833/android-sdk-custom/releases/download/36.0.2/android-sdk-aarch64-linux-musl.tar.xz";
      sha256 = "sha256:5a4989c7d80f60104033eb1121b028ef1124876850796ba816cbed2f7bbe550c";
    }} --strip-components=1 -C $out

    mkdir -p $out/build-tools

    unzip -q ${pkgs.fetchurl {
      url = "https://github.com/ENOA-REIAH-UION/test/releases/download/35.0.0/build-tools-35.zip";
      sha256 = "sha256:ca537f19fb761137eecdb8e28d0c95b16f90120af44d27b402e64a8f4db1bd74";
    }} -d $out/.android-sdk-tools

    cp -r $out/.android-sdk-tools/build-tools/35.0.0 $out/build-tools/35.0.0

    rm -rf $out/.android-sdk-tools
  '';

  androidNdk = pkgs.runCommand "android-ndk" {
    nativeBuildInputs = [ pkgs.xz ];
  } ''
    mkdir -p $out
    tar -xf ${pkgs.fetchurl {
      url = "https://github.com/HomuHomu833/android-ndk-custom/releases/download/r28/android-ndk-r28c-aarch64-linux-musl.tar.xz";
      sha256 = "75a1812035840c83f960599a5a1b4e17385c037fdbfd3e85cae8741bb1f8c5b1";
    }} --strip-components=1 -C $out
  '';

  mkAndroidCmake = version: sha256:
    pkgs.runCommand "android-cmake-${version}" {
      nativeBuildInputs = [ pkgs.gnutar pkgs.gzip pkgs.autoPatchelfHook pkgs.unzip pkgs.patchelf ];
      buildInputs = [ pkgs.stdenv.cc.libc pkgs.stdenv.cc.cc pkgs.ncurses5 pkgs.libxcb pkgs.fontconfig pkgs.freetype];
    } ''
      mkdir -p $out
      tar -xzf ${pkgs.fetchurl {
        url = "https://github.com/Kitware/CMake/releases/download/v${version}/cmake-${version}-linux-aarch64.tar.gz";
        inherit sha256;
      }} --strip-components=1 -C $out
      autoPatchelf $out/bin

      ln -s ${pkgs.ninja_1_11}/bin/ninja $out/bin/ninja
    '';

  cmake3221 = mkAndroidCmake
    "3.22.1"
    "sha256-YBRDN1qhpIoaB2vafjzKc6+IQARj4Wb//D4do84DVAs=";

  cmake3316 = mkAndroidCmake
    "3.31.6"
    "sha256-tMx4jWMRKydJtAYn5xnrXTuO2PAMNtdxifQBnP5kvJ4=";


  mkAndroidPlatform = version: sha256:
    pkgs.runCommand "android-platform-${version}" {
      nativeBuildInputs = [ pkgs.unzip ];
    } ''
      mkdir -p $out
      unzip -q ${pkgs.fetchurl {
        url = "https://dl.google.com/android/repository/platform-${version}_r02.zip";
        inherit sha256;
      }} -d $out
    '';

  platform35 = mkAndroidPlatform
    "35"
    "sha256-CYjKytAbOKGKR7rBSgaV8ka8dsGwbA7rjrDcglqwyOA=";

  platform36 = mkAndroidPlatform
    "36"
    "sha256-N2BzaaKMW2QLOnmYho1FiY68t3dWWg6F+azzbyljHS4=";

  sdkWithNdk = pkgs.runCommand "android-sdk-with-ndk" {} ''
    mkdir -p $out/libexec/android-sdk

    cp -r ${androidSdk}/* $out/libexec/android-sdk/

    mkdir -p $out/libexec/android-sdk/ndk
    ln -s ${androidNdk} $out/libexec/android-sdk/ndk/${ndkVersion}

    mkdir -p $out/libexec/android-sdk/cmake

    ln -s ${cmake3221} $out/libexec/android-sdk/cmake/3.22.1

    ln -s ${cmake3316} $out/libexec/android-sdk/cmake/3.31.6

    mkdir -p $out/libexec/android-sdk/platforms
    cp -r ${platform35}/* $out/libexec/android-sdk/platforms/android-35/
    cp -r ${platform36}/* $out/libexec/android-sdk/platforms/android-36/
  '';

  sdk = "${sdkWithNdk}/libexec/android-sdk";
  ndkPath = "${sdk}/ndk/${ndkVersion}";

in
{
  environment.packages = with pkgs; [
    findutils
    flutter
  ];

  environment.sessionVariables = {
    ANDROID_HOME = sdk;
    ANDROID_SDK_ROOT = sdk;
    ANDROID_NDK_ROOT = ndkPath;
    JAVA_HOME = "${pkgs.jdk17}";
  };

  build.activation.android-gradle-config = ''
    mkdir -p "$HOME/.gradle"

    BUILD_TOOLS_DIR="${sdk}/build-tools"
    LATEST_BUILD_TOOLS="$(ls -1 "$BUILD_TOOLS_DIR" | sort -V | tail -n1)"

    cat > "$HOME/.gradle/gradle.properties" <<EOF
android.aapt2FromMavenOverride=$BUILD_TOOLS_DIR/$LATEST_BUILD_TOOLS/aapt2
org.gradle.console=rich
EOF
  '';

}