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
  android = import ./android-toolchain.nix {
    inherit pkgs;
  };

  androidSdkHome = "$HOME/android-sdk";
in
{
  environment.packages = with pkgs; [
    findutils
    flutter
  ];

  environment.sessionVariables = {
    ANDROID_HOME = androidSdkHome;
    ANDROID_SDK_ROOT = androidSdkHome;

    ANDROID_NDK_ROOT = "${androidSdkHome}/ndk/${android.ndkVersion}";

    JAVA_HOME = "${pkgs.jdk17}";
  };

  build.activation.android-sdk = ''
    set -eu

    SDK="${androidSdkHome}"
    STORE_SDK="${android.sdk}"

    mkdir -p "$SDK"

    # -------------------------------------------------------------------------
    # Nix-managed SDK components
    #
    # Only create/replace symlinks.
    # Never copy SDK contents into $HOME.
    # -------------------------------------------------------------------------

    link_sdk_component() {
      name="$1"
      target="$2"

      if [ -e "$SDK/$name" ] || [ -L "$SDK/$name" ]; then
        rm -rf "$SDK/$name"
      fi

      ln -s "$target" "$SDK/$name"
    }

    # Base SDK components
    for component in \
      platform-tools \
      tools \
      cmdline-tools
    do
      if [ -e "$STORE_SDK/$component" ] || [ -L "$STORE_SDK/$component" ]; then
        link_sdk_component "$component" "$STORE_SDK/$component"
      fi
    done

    # Build tools
    if [ -d "$STORE_SDK/build-tools" ]; then
      link_sdk_component \
        build-tools \
        "$STORE_SDK/build-tools"
    fi

    # NDK
    if [ -d "$STORE_SDK/ndk" ]; then
      link_sdk_component \
        ndk \
        "$STORE_SDK/ndk"
    fi

    # CMake
    if [ -d "$STORE_SDK/cmake" ]; then
      link_sdk_component \
        cmake \
        "$STORE_SDK/cmake"
    fi

    # Licenses
    if [ -d "$STORE_SDK/licenses" ]; then
      link_sdk_component \
        licenses \
        "$STORE_SDK/licenses"
    fi

    # -------------------------------------------------------------------------
    # Marker
    #
    # Useful for debugging which Nix SDK is currently exposed.
    # -------------------------------------------------------------------------

    printf '%s\n' "$STORE_SDK" > "$SDK/.nix-sdk-store-path"
  '';

  build.activation.android-gradle-config = ''
        set -eu

        mkdir -p "$HOME/.gradle"

        SDK="${androidSdkHome}"
        BUILD_TOOLS_DIR="$SDK/build-tools"

        if [ -d "$BUILD_TOOLS_DIR" ]; then
          LATEST_BUILD_TOOLS="$(
            ls -1 "$BUILD_TOOLS_DIR" |
            sort -V |
            tail -n1
          )"

          cat > "$HOME/.gradle/gradle.properties" <<EOF
    android.aapt2FromMavenOverride=$BUILD_TOOLS_DIR/$LATEST_BUILD_TOOLS/aapt2
    org.gradle.console=rich
    EOF
        fi
  '';
}
