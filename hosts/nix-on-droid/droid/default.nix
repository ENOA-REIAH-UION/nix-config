{ mylib, ... }:

{
  imports = builtins.filter
    (p: !(baseNameOf p == "android-toolchain.nix"))
    (mylib.scanPaths ./.);
}