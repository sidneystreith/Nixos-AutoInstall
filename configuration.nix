{ config, pkgs, ... }: {
  imports = [ ./disko-config.nix ]; # Import disk layout

  # Basic system configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "nixos-server";

  # Enable SSH for remote access
  services.openssh.enable = true;

  # Define a root user or additional users
  users.users.root = {
    initialPassword = "temporary"; # Change this or use SSH keys
  };

  # Allow network access during installation
  networking.useDHCP = true;

  environment.systemPackages = with pkgs; [ vim, git, gh, htop ]; # Optional packages
  system.stateVersion = "24.11"; # Match your NixOS version
}
