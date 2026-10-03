{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      forAll = f: nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-linux" ]
        (system: f nixpkgs.legacyPackages.${system});
    in {
      packages = forAll (pkgs: rec {
        # the generator binary: only rebuilt when site.hs / blog.cabal change
        site = pkgs.haskellPackages.callCabal2nix "blog" (pkgs.lib.cleanSourceWith {
          src = ./.;
          filter = path: _: builtins.elem (baseNameOf path) [ "site.hs" "blog.cabal" ];
        }) { };

        # the rendered site: `nix build` -> ./result
        default = pkgs.stdenv.mkDerivation {
          name = "blog-site";
          src = ./.;
          LANG = "C.UTF-8";
          LOCALE_ARCHIVE = pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isLinux
            "${pkgs.glibcLocales}/lib/locale/locale-archive";
          buildPhase = "${site}/bin/site build";
          installPhase = "cp -r _site $out";
        };
      });

      devShells = forAll (pkgs: {
        default = pkgs.haskellPackages.shellFor {
          packages = _: [ self.packages.${pkgs.system}.site ];
          nativeBuildInputs = [ pkgs.cabal-install pkgs.haskell-language-server ];
        };
      });
    };
}
