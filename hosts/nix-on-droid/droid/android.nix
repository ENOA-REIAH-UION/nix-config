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
in
{
  environment.packages = with pkgs; [
    findutils
    flutter
  ];

  environment.sessionVariables = {
    ANDROID_HOME = android.sdk;
    ANDROID_SDK_ROOT = android.sdk;
    ANDROID_NDK_ROOT = android.ndk;
    JAVA_HOME = "${pkgs.jdk17}";
  };

  build.activation.android-gradle-config = ''
        mkdir -p "$HOME/.gradle"

        BUILD_TOOLS_DIR="${android.sdk}/build-tools"

        LATEST_BUILD_TOOLS="$(
          ls -1 "$BUILD_TOOLS_DIR" |
          sort -V |
          tail -n1
        )"

        cat > "$HOME/.gradle/gradle.properties" <<EOF
    android.aapt2FromMavenOverride=$BUILD_TOOLS_DIR/$LATEST_BUILD_TOOLS/aapt2
    org.gradle.console=rich
    EOF
  '';
}
