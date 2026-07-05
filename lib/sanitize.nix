# Turn an upstream version string into a valid (and readable) Nix attr suffix.
#   "6.2.1"   -> "6_2_1"
#   "6.2.1-1" -> "6_2_1_1"
version: builtins.replaceStrings [ "." "-" "+" ] [ "_" "_" "_" ] version
