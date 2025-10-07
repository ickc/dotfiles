{ ... }:
{
  imports = [
    ../modules/common.nix
    ../modules/shell.nix
  ];

  system.primaryUser = "kolen";
}
