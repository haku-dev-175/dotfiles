{
  description = "Multi-platform Nix configuration (NixOS + macOS + WSL)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For macOS
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }:
    let
      localConfig = import ./local.nix;
    in
    {
      # ========================================
      # NixOS Configuration (Linux)
      # ========================================
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit localConfig; };
          modules = [
            ./nixos/configuration.nix

            # Integrate home-manager as NixOS module
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${localConfig.username} = import ./home-manager/home.nix;
              home-manager.extraSpecialArgs = {
                machineConfig = {
                  username = localConfig.username;
                  homeDirectory = localConfig.homeDirectory;
                  extraFishPaths = localConfig.extraFishPaths;
                };
              };
            }
          ];
        };
      };

      # ========================================
      # macOS Configuration (nix-darwin)
      # ========================================
      darwinConfigurations = {
        mac = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./darwin/configuration.nix

            # Integrate home-manager
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${localConfig.username} = import ./home-manager/home.nix;
              home-manager.extraSpecialArgs = {
                machineConfig = {
                  username = localConfig.username;
                  homeDirectory = localConfig.homeDirectory;
                  extraFishPaths = localConfig.extraFishPaths;
                };
              };
            }
          ];
        };
      };

      # ========================================
      # WSL Configuration (home-manager standalone)
      # ========================================
      homeConfigurations = {
        wsl = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./home-manager/home.nix
          ];
          extraSpecialArgs = {
            machineConfig = {
              username = localConfig.username;
              homeDirectory = localConfig.homeDirectory;
              extraFishPaths = localConfig.extraFishPaths;
            };
          };
        };
      };
    };
}
