#!/bin/bash

# lsblk to check disk

# Exit on any error
set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Variables (customize these as needed)
DISK="/dev/sda"
ROOT_LABEL="nixos"
SWAP_LABEL="swap"
BOOT_LABEL="boot"
SWAP_SIZE="16G"

echo "Starting NixOS installation on $DISK..."

# Partitioning for UEFI
echo "Creating partition table..."
parted $DISK -- mklabel gpt
parted $DISK -- mkpart root ext4 512MB -${SWAP_SIZE}
# parted $DISK -- mkpart swap linux-swap -${SWAP_SIZE} 100%
parted $DISK -- mkpart ESP fat32 1MB 512MB
parted $DISK -- set 3 esp on

# Formatting
echo "Formatting partitions..."
mkfs.ext4 -L $ROOT_LABEL ${DISK}1
# mkswap -L $SWAP_LABEL ${DISK}2
mkfs.fat -F 32 -n $BOOT_LABEL ${DISK}3

# Mounting
echo "Mounting filesystems..."
mount /dev/disk/by-label/$ROOT_LABEL /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/$BOOT_LABEL /mnt/boot
# swapon /dev/disk/by-label/$SWAP_LABEL

# Generate configuration
echo "Generating NixOS configuration..."
nixos-generate-config --root /mnt

# Basic configuration modification
echo "Configuring basic system settings..."
cat << EOF > /mnt/etc/nixos/configuration.nix
{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

# Use the grub boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "summercamp"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "de-latin1-nodeadkeys";

  users.users = {
    sidney = {
      initialPassword = "s1";
      isNormalUser = true;
      description = "Sidney Streith";
      extraGroups = [ "networkmanager" "wheel" ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}
EOF

# Install NixOS
echo "Installing NixOS..."
nixos-install --no-root-passwd

# Set root password (optional, uncomment to use)
# echo "Setting root password..."
# echo "root:changeme" | chpasswd

# Set user password (optional, uncomment to use)
# echo "Setting user password..."
# nixos-enter --root /mnt -c 'echo "nixos:changeme" | chpasswd'

echo "Installation complete! Please review the configuration and reboot."
echo "After reboot, log in and change the default passwords."
