# Builds a single pocket-sync package from one data/pocket-sync.json entry.
#
# pocket-sync ships a prebuilt amd64 .deb, so each release carries a single
# content hash (`srcHash`) for the fetched archive. dpkg-deb unpacks it,
# autoPatchelfHook rewrites the ELF against nixpkgs, and wrapGAppsHook3 sets up
# the GTK/WebKit environment. x86_64-linux only.
{
  pkgs,
  lib,
  entry,
}:

let
  inherit (entry) version srcHash;
in
pkgs.stdenv.mkDerivation {
  pname = "pocket-sync";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://github.com/neil-morrison44/pocket-sync/releases/download/v${version}/Pocket.Sync_${version}_amd64.deb";
    hash = srcHash;
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

  meta = with lib; {
    description = "Sync tool for the Analogue Pocket";
    homepage = "https://github.com/neil-morrison44/pocket-sync";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "pocket-sync";
  };
}
