{
  description = "pocket-sync - sync tool for the Analogue Pocket, version-selectable";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      # Single source of truth for every packaged release.
      pocketSyncData = builtins.fromJSON (builtins.readFile ./data/pocket-sync.json);

      mkPackages =
        pkgs:
        import ./lib/mk-packages.nix {
          inherit pkgs pocketSyncData;
          lib = pkgs.lib;
        };
    in
    {
      # Fold every pocket-sync_*/pocket-sync package into a consumer's nixpkgs.
      # Build from `prev` (leaf packages that don't reference each other), and drop
      # the `default` alias so consumers don't get a stray `pkgs.default`.
      overlays.default = _final: prev: removeAttrs (mkPackages prev) [ "default" ];
    }
    # Prebuilt amd64 .deb -> x86_64-linux is the only buildable target.
    // flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # `nix run .#update` appends the newest release to data/pocket-sync.json.
        update = pkgs.writeShellApplication {
          name = "pocket-sync-update";
          runtimeInputs = [
            pkgs.curl
            pkgs.jq
            pkgs.coreutils
            pkgs.gnugrep
            pkgs.nix
          ];
          text = ''exec bash ${./updater/update.sh} "$@"'';
        };
      in
      {
        packages = mkPackages pkgs;

        apps.pocket-sync = flake-utils.lib.mkApp {
          drv = self.packages.${system}.pocket-sync;
        };
        apps.default = self.apps.${system}.pocket-sync;

        apps.update = {
          type = "app";
          program = "${update}/bin/pocket-sync-update";
          meta.description = "Append the newest pocket-sync release to data/pocket-sync.json";
        };

        formatter = pkgs.nixfmt;
      }
    );
}
