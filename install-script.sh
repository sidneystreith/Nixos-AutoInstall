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
DISK="/dev/vda"
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
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname

  # Enable networking
  networking.networkmanager.enable = true;

  # Set time zone
  time.timeZone = "UTC";

  # Basic packages
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Enable OpenSSH
  services.openssh.enable = true;

  # Create a user (customize username and password)
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "changeme";
  };

  system.stateVersion = "24.05"; # Adjust based on your version
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
