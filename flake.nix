{
  description = "Ryan Yin's NixOS and Nix-on-Droid configuration";

  ##################################################################################################################
  #
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-2505,
      nixpkgs-stable,
      nixpkgs-patched,
      nixpkgs-master,
      home-manager,
      nixos-generators,
      nix-on-droid,
      pre-commit-hooks,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      mylib = import ./lib { inherit lib; };
      myvars = import ./vars { inherit lib; };

      # systems this flake targets
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = lib.genAttrs systems;

      genSpecialArgs =
        system:
        inputs
        // {
          inherit mylib myvars;

          pkgs-2505 = import nixpkgs-2505 {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs-patched = import nixpkgs-patched {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs-master = import nixpkgs-master {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs-x64 = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
            overlays = import ./overlays inputs;
          };
        };

      x86BaseArgs = {
        inherit
          inputs
          lib
          mylib
          myvars
          genSpecialArgs
          ;
        system = "x86_64-linux";
      };

      k8sHosts = {
        "k3s-prod-1-master-1" = {
          home = [ ./home/hosts/linux/k3s-prod-1-master-1.nix ];
        };
        "k3s-prod-1-master-2" = { };
        "k3s-prod-1-master-3" = { };
        "k3s-prod-1-worker-1" = { };
        "k3s-prod-1-worker-2" = { };
        "k3s-prod-1-worker-3" = { };
        "k3s-test-1-master-1" = {
          home = [ ./home/hosts/linux/k3s-test-1-master-1.nix ];
        };
        "k3s-test-1-master-2" = { };
        "k3s-test-1-master-3" = { };
        "kubevirt-shoryu" = {
          tags = [ "virt-shoryu" ];
          iso = true;
        };
        "kubevirt-shushou" = {
          tags = [ "virt-shushou" ];
          iso = true;
          preservation = true;
        };
        "kubevirt-youko" = {
          tags = [ "virt-youko" ];
          iso = true;
          preservation = true;
        };
      };

      mkK8s =
        name: host:
        let
          tags = [ name ] ++ (host.tags or [ ]);
          commonModules = [
            ./secrets/nixos.nix
            ./modules/nixos/server/server.nix
          ];
          hardwareModule = lib.optional (
            !lib.hasPrefix "kubevirt-" name
          ) ./modules/nixos/server/kubevirt-hardware-configuration.nix;
          hostModule = ./hosts/k8s/${name};
          extraModules = [
            { modules.secrets.server.kubernetes.enable = true; }
          ]
          ++ lib.optional (host.preservation or false) {
            modules.secrets.preservation.enable = true;
          };
          modules = commonModules ++ hardwareModule ++ [ hostModule ] ++ extraModules;
          args = x86BaseArgs // {
            inherit modules;
            nixos-modules = modules;
            home-modules = host.home or [ ];
          };
          config = mylib.nixosSystem args;
        in
        {
          inherit config tags;
          iso = host.iso or false;
          colmena = mylib.colmenaSystem (
            args
            // {
              inherit tags;
              ssh-user = "root";
            }
          ) { name = name; };
        };

      k8s = lib.mapAttrs mkK8s k8sHosts;

      idolsAi =
        let
          modules = [
            ./secrets/nixos.nix
            ./modules/nixos/desktop.nix
            ./hosts/idols-ai
            ./hardening/nixpaks
            ./hardening/bwraps
            {
              programs.niri.enable = true;
              modules.desktop.fonts.enable = true;
              modules.desktop.wayland.enable = true;
              modules.secrets.desktop.enable = true;
              modules.secrets.preservation.enable = true;
              modules.desktop.gaming.enable = true;
            }
          ];
          args = x86BaseArgs // {
            nixos-modules = modules;
            home-modules = [ ./home/hosts/linux/idols-ai.nix ];
          };
        in
        mylib.nixosSystem args;

      nixosConfigurations = (lib.mapAttrs (name: host: host.config) k8s) // {
        "ai-niri" = idolsAi;
      };

      colmena = {
        meta = {
          nixpkgs = import nixpkgs { system = "x86_64-linux"; };
          specialArgs = genSpecialArgs "x86_64-linux";
        };
      }
      // lib.mapAttrs (name: host: host.colmena) k8s;

      packages.x86_64-linux =
        (lib.mapAttrs (
          name: host: if host.iso then host.config.config.formats.iso else host.config.config.formats.kubevirt
        ) k8s)
        // {
          "ai-niri" = idolsAi.config.formats.iso;
        };

      # Nix-on-Droid is intentionally kept small for now: TUI only.
      nixOnDroidConfigurations."nix-on-droid" = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = inputs // {
          inherit inputs mylib myvars;
          pkgs-master = import nixpkgs-master {
            system = "aarch64-linux";
            config.allowUnfree = true;
          };
        };
        modules = [ ./hosts/nix-on-droid ];
      };

      ##############################################################################
      # Formatting / linting tooling, available on every supported system.
      ##############################################################################

      checks = forAllSystems (system: {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style = {
              enable = true;
              settings.width = 100;
            };
            typos = {
              enable = true;
              settings = {
                write = true;
                configPath = ".typos.toml";
                exclude = "rime-data/";
              };
            };
            prettier = {
              enable = true;
              settings = {
                write = true;
                configPath = ".prettierrc.yaml";
              };
            };
          };
        };
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              bashInteractive
              gcc
              nixfmt
              deadnix
              statix
              typos
              prettier
            ];
            name = "dots";
            shellHook = self.checks.${system}.pre-commit-check.shellHook;
          };
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    in
    {
      inherit
        nixosConfigurations
        colmena
        packages
        checks
        devShells
        formatter
        nixOnDroidConfigurations
        ;
    };

  # the nixConfig here only affects the flake itself, not the system configuration!
  # for more information, see:
  #     https://nixos-and-flakes.thiscute.world/nix-store/add-binary-cache-servers
  nixConfig = {
    # substituers will be appended to the default substituters when fetching packages
    extra-substituters = [
      "https://cache.numtide.com"
      # "https://nix-gaming.cachix.org"
      # "https://nixpkgs-wayland.cachix.org"
      # "https://install.determinate.systems"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      # "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      # "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      # "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs. The most widely used is github:owner/name/reference,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using nixos's unstable branch by default
    # Find git commit hash with build status here(3 jobs per day):
    # https://hydra.nixos.org/jobset/nixpkgs/unstable
    # update via nix flake update nixpkgs --override-input nixpkgs github:NixOS/nixpkgs/<commit-hash>
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05";

    # nixpkgs with some custom patches
    nixpkgs-patched.url = "github:ryan4yin/nixpkgs/nixos-unstable-patched";
    # get some latest packages from the master branch
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "github:nix-community/home-manager/release-26.05";

      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/catppuccin/nix
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation = {
      url = "github:nix-community/preservation";
    };

    # generate iso/qcow2/docker/... image from nixos configuration
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # secrets management
    agenix = {
      # lock with git commit at May 18, 2025
      url = "github:ryantm/agenix/4835b1dc898959d8547a871ef484930675cb47f1";
      # replaced with a type-safe reimplementation to get a better error message and less bugs.
      # url = "github:ryan4yin/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/v1.13.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # add git hooks to format nix code before commit
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nuenv = {
      url = "github:DeterminateSystems/nuenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    blender-bin = {
      url = "github:edolstra/nix-warez?dir=blender";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # AI coding agents
    llm-agents.url = "github:numtide/llm-agents.nix";

    # -------------- Gaming ---------------------

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xmcl = {
      url = "github:x45iq/xmcl-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix/main";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    ########################  Some non-flake repositories  #########################################

    nu_scripts = {
      url = "github:nushell/nu_scripts";
      flake = false;
    };

    ########################  My own repositories  #########################################

    # my private secrets, it's a private repository, you need to replace it with your own.
    # use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone to save time
    mysecrets = {
      url = "git+https://git@github.com/ENOA-REIAH-UION/nix-secrets.git?shallow=1";
      flake = false;
    };

    # my-asahi-firmware = {
    #   url = "git+ssh://git@github.com/ryan4yin/asahi-firmware.git?shallow=1";
    #   flake = false;
    # };

    # my wallpapers
    wallpapers = {
      url = "github:ENOA-REIAH-UION/wallpapers";
      flake = false;
    };

    nur-ryan4yin = {
      url = "github:ryan4yin/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Wayland <-> X11 clipboard sync daemon for xwayland-satellite (niri)
    pyclipsync = {
      url = "github:ryan4yin/pyclipsync";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
