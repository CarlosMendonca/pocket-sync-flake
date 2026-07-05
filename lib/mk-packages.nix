# Builds the full attrset of pocket-sync packages for `pkgs`' own system: one
# `pocket-sync_<version>` per release, plus a `pocket-sync` alias for the newest
# and a `default`. Shared by `packages.<system>` and `overlays.default` so the
# two can never drift apart.
{
  pkgs,
  lib,
  pocketSyncData,
}:

let
  sanitize = import ./sanitize.nix;

  mkPocketSync = entry: import ./mk-pocket-sync.nix { inherit pkgs lib entry; };

  # `pocket-sync_<sanitized version>` for every release.
  named = lib.listToAttrs (
    map (e: {
      name = "pocket-sync_${sanitize e.version}";
      value = mkPocketSync e;
    }) pocketSyncData
  );

  # Highest version in the data set (null if the list is somehow empty).
  latest =
    if pocketSyncData == [ ] then
      null
    else
      lib.foldl' (
        acc: e: if builtins.compareVersions e.version acc.version > 0 then e else acc
      ) (builtins.head pocketSyncData) pocketSyncData;
in
named
# `pocket-sync` -> newest release; `default` so a plain `nix run`/`nix build` works.
// lib.optionalAttrs (latest != null) {
  pocket-sync = mkPocketSync latest;
  default = mkPocketSync latest;
}
