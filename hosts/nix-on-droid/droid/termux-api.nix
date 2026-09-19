{ config, pkgs, ... }:

# NOTE: The termux-api-app APK must be modified to set
# manifestPlaceholders.TERMUX_PACKAGE_NAME to "com.termux.nix"
# instead of the default "com.termux".
#
# Two approaches are available:
#   1. Rebuild the app with the modified build configuration.
#   2. Decompile the existing APK and modify its manifest directly (more convenient).
#
# Reference:
#   https://github.com/nix-community/nix-on-droid/issues/133#issuecomment-4273168797
let
  android = import ./android-toolchain.nix {
    inherit pkgs;
  };

  ndk = android.ndk;
in
{
  environment.packages = [
    (pkgs.stdenv.mkDerivation rec {
      pname = "termux-api";
      version = "v0.59.1";

      src = pkgs.fetchgit {
        url = "https://github.com/termux/termux-api-package";
        rev = version;
        sha256 = "h3aYpY/5rddAd1w8K0l0JdrazvCH3utizir1RGmXbd4=";
      };

      nativeBuildInputs = [ pkgs.cmake ];

      cmakeFlags = [
        "-DCMAKE_TOOLCHAIN_FILE=${ndk}/build/cmake/android.toolchain.cmake"
        "-DANDROID_ABI=arm64-v8a"
        "-DANDROID_PLATFORM=android-21"
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
      ];

      postPatch = ''
        substituteInPlace termux-api.c \
          --replace 'execv(PREFIX "/bin/am", child_argv);' \
                    'execv("/data/data/com.termux.nix/files/home/.nix-profile/bin/am", child_argv);'
      '';

      preConfigure = ''
        [ -f "${ndk}/build/cmake/android.toolchain.cmake" ] || {
          echo "Invalid ANDROID_NDK_ROOT: ${ndk}"
          exit 1
        }

        for f in scripts/* termux-callback.in; do
          sed -i '1c#!${pkgs.runtimeShell}' "$f"
          sed -i 's|@TERMUX_PREFIX@/libexec/|@TERMUX_PREFIX@/bin/|g' "$f"
        done
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/{bin,lib,libexec}

        cp scripts/* $out/bin/
        cp termux-api-broadcast $out/bin/

        cat > $out/bin/termux-api <<EOF
        #!${pkgs.runtimeShell}
        export LD_LIBRARY_PATH="/data/data/com.termux.nix/files/home/.nix-profile/lib:\$LD_LIBRARY_PATH"
        exec "/data/data/com.termux.nix/files/home/.nix-profile/bin/termux-api-broadcast" "\$@"
        EOF

        chmod +x $out/bin/*

        cp termux-callback $out/libexec/
        cp libtermux-api.so $out/lib/

        runHook postInstall
      '';
    })
  ];

  android-integration.am.enable = true;
}
