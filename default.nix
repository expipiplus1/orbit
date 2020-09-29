{ nixpkgsSrc ? builtins.fetchTarball
  "https://github.com/NixOS/nixpkgs/archive/1179840f9a88b8a548f4b11d1a03aa25a790c379.tar.gz"
, pkgs ? import nixpkgsSrc { }, compiler ? null, hoogle ? true }:

let
  src = pkgs.nix-gitignore.gitignoreSource [ ] ./.;

  compiler' = if compiler != null then
    compiler
  else
    "ghc" + pkgs.lib.concatStrings
    (pkgs.lib.splitVersion pkgs.haskellPackages.ghc.version);

  # Any overrides we require to the specified haskell package set
  haskellPackages = with pkgs.haskell.lib;
    pkgs.haskell.packages.${compiler'}.override {
      overrides = self: super:
        {
          exact-real = markUnbroken (dontCheck (doJailbreak super.exact-real));
        } // pkgs.lib.optionalAttrs hoogle {
          ghc = super.ghc // { withPackages = super.ghc.withHoogle; };
          ghcWithPackages = self.ghc.withPackages;
        };
    };

  # Any packages to appear in the environment provisioned by nix-shell
  extraEnvPackages = with haskellPackages; [ ];

  # Generate a haskell derivation using the cabal2nix tool on `package.yaml`
  drv = let old = haskellPackages.callCabal2nix "" src { };
  in old // {
    # Insert the extra environment packages into the environment generated by
    # cabal2nix
    env = pkgs.lib.overrideDerivation old.env (attrs:
      {
        buildInputs = attrs.buildInputs ++ extraEnvPackages;
      } // pkgs.lib.optionalAttrs hoogle {
        shellHook = attrs.shellHook + ''
          export HIE_HOOGLE_DATABASE="$(cat $(${pkgs.which}/bin/which hoogle) | sed -n -e 's|.*--database \(.*\.hoo\).*|\1|p')"
        '';
      });
  };

in if pkgs.lib.inNixShell then drv.env else drv
