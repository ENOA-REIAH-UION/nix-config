{ lib, pkgs, ... }:

{
  time.timeZone = "Asia/Shanghai";

  environment.sessionVariables = {
    LANG = "zh_CN.UTF-8";
    # LC_ALL = "zh_CN.UTF-8";
  };
}