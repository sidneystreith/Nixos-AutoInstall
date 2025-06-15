{
  description = "Automated NixOS Server Installation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # Specify your desired NixOS version
    disko.url = "github:nix-community/disko";         # Include disko for disk management
    disko.inputs.nixpkgs.follows = "nixpkgs";         # Ensure disko uses the same nixpkgs
  };

  outputs = { self, nixpkgs, disko, ... }: {
    nixosConfigurations.summercamp = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # Adjust for your server's architecture
      modules = [
        disko.nixosModules.disko # Include disko module
        ./configuration.nix     # System configuration
        ./disko-config.nix      # Disk layout configuration
      ];
    };
  };
}
