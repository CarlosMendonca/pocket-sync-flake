{
  description = "pocket-sync - sync tool for the Analogue Pocket";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        version = "6.1.1";
      in {
        packages.pocket-sync = pkgs.stdenv.mkDerivation {
          pname = "pocket-sync";
          inherit version;

          src = pkgs.fetchurl {
            url = "https://github.com/neil-morrison44/pocket-sync/releases/download/v${version}/Pocket.Sync_${version}_amd64.deb";
            hash = "sha256-JKsIsbnk/7nP53C5a/xxQ/22GwG/DZ3MF+ySxLHNAP4=";
          };

          nativeBuildInputs = with pkgs; [
            dpkg
            autoPatchelfHook
            wrapGAppsHook3
          ];

          buildInputs = with pkgs; [
            gtk3
            glib
            webkitgtk_4_1
            openssl
            libayatana-appindicator
          ];

          unpackPhase = "dpkg-deb -x $src .";

          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            cp usr/bin/pocket-sync $out/bin/pocket-sync
            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Sync tool for the Analogue Pocket";
            homepage = "https://github.com/neil-morrison44/pocket-sync";
            license = licenses.agpl3Only;
            platforms = [ "x86_64-linux" ];
            mainProgram = "pocket-sync";
          };
        };

        packages.default = self.packages.${system}.pocket-sync;

        apps.pocket-sync = flake-utils.lib.mkApp {
          drv = self.packages.${system}.pocket-sync;
        };
        apps.default = self.apps.${system}.pocket-sync;
      });
}
