# pocket-sync-flake

Nix flake for [pocket-sync](https://github.com/neil-morrison44/pocket-sync), a sync tool for the [Analogue Pocket](https://www.analogue.co/pocket) by [neil-morrison44](https://github.com/neil-morrison44).

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

### Use in a NixOS or home-manager configuration

Add the flake as an input. To always follow the latest version:

```nix
inputs.pocket-sync.url = "github:CarlosMendonca/pocket-sync-flake";
```

To pin a specific version:

```nix
inputs.pocket-sync.url = "github:CarlosMendonca/pocket-sync-flake?ref=v5.11.0";
```

To reuse your existing nixpkgs instead of pulling in a separate one:

```nix
inputs.pocket-sync.inputs.nixpkgs.follows = "nixpkgs";
```

Then add the package:

```nix
environment.systemPackages = [ inputs.pocket-sync.packages.${system}.pocket-sync ];
# or in home-manager:
home.packages = [ inputs.pocket-sync.packages.${system}.pocket-sync ];
```

### Build locally

```bash
git clone https://github.com/CarlosMendonca/pocket-sync-flake
cd pocket-sync-flake
nix build
./result/bin/pocket-sync
```

## Current version

pocket-sync [v6.1.1](https://github.com/neil-morrison44/pocket-sync/releases/tag/v6.1.1)
