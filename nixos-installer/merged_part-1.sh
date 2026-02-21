# NOTE: `cat README.md | grep part-1 > part-1.sh` to generate this script
parted /dev/nvme0n1 -- mklabel gpt  # part-1
parted /dev/nvme0n1 -- mkpart ESP fat32 2MB 629MB  # part-1
parted /dev/nvme0n1 -- set 1 esp on  # part-1
parted /dev/nvme0n1 -- mkpart primary 630MB 100%  # part-1

# NOTE: `cat shoukei.md | grep luks > luks.sh` to generate this script
# encrypt the root partition with luks2 and argon2id, will prompt for a passphrase, which will be used to unlock the partition.
cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --hash sha512 --iter-time 5000 --key-size 256 --pbkdf argon2id --use-random --verify-passphrase /dev/nvme0n1p2
cryptsetup luksDump /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 crypted-nixos

mkfs.fat -F 32 -n ESP /dev/nvme0n1p1  # create-btrfs
mkfs.btrfs -L crypted-nixos /dev/mapper/crypted-nixos   # create-btrfs
mount /dev/mapper/crypted-nixos /mnt  # create-btrfs
btrfs subvolume create /mnt/@nix  # create-btrfs
btrfs subvolume create /mnt/@guix  # create-btrfs
btrfs subvolume create /mnt/@tmp  # create-btrfs
btrfs subvolume create /mnt/@swap  # create-btrfs
btrfs subvolume create /mnt/@persistent  # create-btrfs
btrfs subvolume create /mnt/@snapshots  # create-btrfs
umount /mnt  # create-btrfs

# NOTE: `cat shoukei.md | grep mount-1 > mount-1.sh` to generate this script
mkdir /mnt/{nix,gnu,tmp,swap,persistent,snapshots,boot}  # mount-1
mount -o compress-force=zstd:1,noatime,subvol=@nix /dev/mapper/crypted-nixos /mnt/nix  # mount-1
mount -o compress-force=zstd:1,noatime,subvol=@guix /dev/mapper/crypted-nixos /mnt/gnu  # mount-1
mount -o compress-force=zstd:1,subvol=@tmp /dev/mapper/crypted-nixos /mnt/tmp  # mount-1
mount -o subvol=@swap /dev/mapper/crypted-nixos /mnt/swap  # mount-1
mount -o compress-force=zstd:1,noatime,subvol=@persistent /dev/mapper/crypted-nixos /mnt/persistent  # mount-1
mount -o compress-force=zstd:1,noatime,subvol=@snapshots /dev/mapper/crypted-nixos /mnt/snapshots  # mount-1
mount /dev/nvme0n1p1 /mnt/boot  # mount-1
btrfs filesystem mkswapfile --size 96g --uuid clear /mnt/swap/swapfile  # mount-1
swapon /mnt/swap/swapfile  # mount-1
