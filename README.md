# pocket-sync-flake

Nix flake for [pocket-sync](https://github.com/neil-morrison44/pocket-sync), a sync tool for the [Analogue Pocket](https://www.analogue.co/pocket) by [neil-morrison44](https://github.com/neil-morrison44).

Every release is exposed as its own package attribute (`pocket-sync_6_2_1`), and `pocket-sync`/`default` always track the newest. x86_64-linux only (upstream ships an amd64 `.deb`).

## Usage

### Run without installing

```bash
nix run github:CarlosMendonca/pocket-sync-flake
```

### Try in a temporary shell

```bash
nix shell github:CarlosMendonca/pocket-sync-flake
pocket-sync
```

### Run or install a specific version

Each release is available as `pocket-sync_<version>`, with dots replaced by underscores:

```bash
nix run   github:CarlosMendonca/pocket-sync-flake#pocket-sync_5_11_0
nix shell github:CarlosMendonca/pocket-sync-flake#pocket-sync_6_2_1
nix profile install github:CarlosMendonca/pocket-sync-flake#pocket-sync_6_2_1
```

### Use in a NixOS or home-manager configuration

Add the flake as an input:

```nix
inputs.pocket-sync.url = "github:CarlosMendonca/pocket-sync-flake";
```

To reuse your existing nixpkgs instead of pulling in a separate one:

```nix
inputs.pocket-sync.inputs.nixpkgs.follows = "nixpkgs";
```

Then add a package — either the latest or a pinned version:

```nix
environment.systemPackages = [
  inputs.pocket-sync.packages.${system}.pocket-sync          # newest
  # inputs.pocket-sync.packages.${system}.pocket-sync_5_11_0 # a specific release
];
# or in home-manager:
home.packages = [ inputs.pocket-sync.packages.${system}.pocket-sync ];
```

### As an overlay

Apply `overlays.default` to fold every version into your `pkgs`:

```nix
nixpkgs.overlays = [ inputs.pocket-sync.overlays.default ];
# then, anywhere pkgs is in scope:
environment.systemPackages = [
  pkgs.pocket-sync          # newest
  # pkgs.pocket-sync_5_11_0 # a specific release
];
```

### Legacy version pinning

Older releases remain reachable through git-tag pinning as well:

```nix
inputs.pocket-sync.url = "github:CarlosMendonca/pocket-sync-flake?ref=v5.11.0";
```

### Build locally

```bash
git clone https://github.com/CarlosMendonca/pocket-sync-flake
cd pocket-sync-flake
nix build
./result/bin/pocket-sync
```

## Adding a new release

`data/pocket-sync.json` is the single source of truth. To append the latest upstream release (computing its `srcHash`):

```bash
nix run .#update
```

This runs automatically every week via GitHub Actions.

## Current version

pocket-sync [v6.4.0](https://github.com/neil-morrison44/pocket-sync/releases/tag/v6.4.0)
