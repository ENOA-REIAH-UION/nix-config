# Nix 环境配置 - Idols - Ai 主机

> :red_circle: **重要提示**: **请勿直接在您的机器上部署此 flake。** 请从头编写您自己的配置，只将本项目作为参考。

此 flake 用于在全新机器上准备 Nix 环境，以设置桌面主机 [hosts/idols-ai](../hosts/idols-ai/)（来自主 flake）。

其他文档：

- [README for 12kingdomed-shoukei](./README.shoukei.md)

## 为什么要用这个 flake

主 flake 体积庞大且部署缓慢。这个轻量级 flake 有助于：

1. 在部署主 flake 之前，调整并验证 `hardware-configuration.nix` 和磁盘布局。
2. 在虚拟机或全新安装中测试数据持久化、Secure Boot、TPM2、加密等功能。

磁盘布局通过 [disko](https://github.com/nix-community/disko) 实现**声明式**配置，无需手动分区。

## 部署步骤

### 准备工作

1. 从官方 NixOS ISO 创建 USB 安装介质并启动。

### 1. 使用 disko 分区和挂载（推荐）

磁盘布局定义在 [../hosts/idols-ai/disko-fs.nix](../hosts/idols-ai/disko-fs.nix)：
- 目标磁盘：**nvme1n1**
- 分区结构：ESP (450M) + LUKS + btrfs
- btrfs 子卷：@nix, @guix, @persistent, @snapshots, @tmp, @swap
- 根目录使用 tmpfs；[preservation](https://github.com/nix-community/preservation) 使用 `/persistent`

```bash
git clone https://github.com/ryan4yin/nix-config.git
cd nix-config/nixos-installer

sudo su

# 使用 luks2 + argon2id 加密根分区，会提示输入密码用于解锁分区
# 警告：会清除 nvme1n1 上的所有数据！布局默认挂载到 /mnt
nix run github:nix-community/disko -- --mode destroy,format,mount ../hosts/idols-ai/disko-fs.nix

# 仅挂载（例如首次格式化后，无需清除数据）：
# nix run github:nix-community/disko -- --mode mount ../hosts/idols-ai/disko-fs.nix

# 设置通过 TPM2 芯片自动解锁
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/<加密磁盘分区路径>
```

### 2. 安装 NixOS

```bash
sudo su

# 添加 ssh 密钥到 ssh-agent（用于拉取 asahi-firmware）
$(ssh-agent)
ssh-add /path/to/ssh-key

# 从 nix-config/nixos-installer 目录执行
nixos-install --root /mnt --flake .#ai --no-root-password
```

### 3. 复制数据到 /persistent 并重启

Preservation 期望数据存放在 `/persistent`；将数据复制或迁移到该目录（例如从旧磁盘），然后退出 chroot 并重启。

```bash
nixos-enter

# 根据需要复制/迁移数据到 /persistent（例如从旧 nvme0n1）
# 全新安装至少需要：
#   mkdir -p /persistent/etc
#   mv /etc/machine-id /persistent/etc/
#   mv /etc/ssh /persistent/etc/
# 完成后执行 exit 和：
exit
umount -R /mnt
reboot
```

重启后在固件中设置启动顺序，使系统从 nvme1n1 启动。旧磁盘（如 nvme0n1）可另作他用。

### 可选：使用缓存镜像加速

```bash
nixos-install --root /mnt --flake .#ai --no-root-password \
  --option substituters "https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/"
```

## 首次启动后部署主配置

### 1. 配置 SSH 密钥（用于拉取私有 secrets 仓库）

```bash
ssh-keygen -t ed25519 -a 256 -C "ryan@idols-ai" -f ~/.ssh/idols_ai
ssh-add ~/.ssh/idols_ai
```

### 2. 重新生成 secrets

按照 [../secrets/README.md](../secrets/README.md) 的说明重新生成 secrets，使 agenix 能够使用此主机的 SSH 密钥进行解密。

### 3. 部署主配置

```bash
sudo mv /etc/nixos ~/nix-config
sudo chown -R ryan:ryan ~/nix-config
cd ~/nix-config
just hypr
```

### 4. 配置 Secure Boot

按照以下文档配置：
- [lanzaboote Quick Start](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md)
- [hosts/idols-ai/secureboot.nix](../hosts/idols-ai/secureboot.nix)

## 升级系统

现在使用 disko 进行分区后，升级系统变得非常简单：

```bash
# 进入 nix-config 目录
cd ~/nix-config

# 升级 NixOS 配置（等同于 nixos-rebuild switch --flake .#ai）
just hypr

# 或者手动执行
sudo nixos-rebuild switch --flake .#ai
```

如果你只是修改了 flake 输入（如更新 nixpkgs 版本），需要先更新锁文件：

```bash
# 更新 flake 依赖
nix flake update

# 然后重新构建
sudo nixos-rebuild switch --flake .#ai
```

## 修改磁盘布局

如果需要调整分区或子卷布局，编辑 [../hosts/idols-ai/disko-fs.nix](../hosts/idols-ai/disko-fs.nix)，然后重新运行 disko：

```bash
# 重新格式化（会清除数据！）
nix run github:nix-community/disko -- --mode destroy,format,mount ../hosts/idols-ai/disko-fs.nix

# 或者仅挂载（不重新格式化）
nix run github:nix-community/disko -- --mode mount ../hosts/idols-ai/disko-fs.nix
```

## 修改 LUKS2 密码

```bash
# 测试当前密码
sudo cryptsetup --verbose open --test-passphrase /path/to/device

# 修改密码
sudo cryptsetup luksChangeKey /path/to/device

# 验证
sudo cryptsetup --verbose open --test-passphrase /path/to/device
```

## 参考：磁盘布局说明

布局结构（ESP + LUKS + btrfs，临时根目录，`/persistent` 持久化）详见
[../hosts/idols-ai/disko-fs.nix](../hosts/idols-ai/disko-fs.nix)。

相关资料：

- [NixOS 手动安装指南](https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning)
- [dm-crypt / 加密整个系统 (Arch)](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system)
- [cryptsetup FAQ](https://gitlab.com/cryptsetup/cryptsetup/wikis/FrequentlyAskedQuestions)
