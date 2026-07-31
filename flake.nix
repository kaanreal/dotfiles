{
  description = "kaan's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell.url = "github:caelestia-dots/shell";

    caelestia-dots = {
      url = "github:caelestia-dots/caelestia";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    caelestia-shell,
    caelestia-dots,
    ...
  }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nixos
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit caelestia-dots caelestia-shell;
          };
          home-manager.users.kaan = import ./home/kaan;
        }
      ];
    };
  };
}
