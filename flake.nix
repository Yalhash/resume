{
  description = "Nix flake for building my resume";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-24.11;
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      tex = pkgs.texlive.combine {
          # NOTE Got all of these from https://ctan.org/search?phrase=<search for thing missing>
          inherit (pkgs.texlive) scheme-minimal latex-bin latexmk geometry xcolor nopageno enumitem psnfss hyperref pdftexcmds infwarerr kvoptions etoolbox;
      };
    in rec {
      packages = {
        document = pkgs.stdenvNoCC.mkDerivation rec {
          name = "resume";
          src = self;
          buildInputs = [ pkgs.coreutils tex ];
          phases = ["unpackPhase" "buildPhase" "installPhase"];
          buildPhase = ''
            export PATH="${pkgs.lib.makeBinPath buildInputs}";
            mkdir -p .cache/texmf-var
            env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
              latexmk -interaction=nonstopmode -pdf -lualatex \
              resume.tex
          '';
          installPhase = ''
            mkdir -p $out
            cp resume.pdf $out/
          '';
        };
      };
      defaultPackage = packages.document;
    });
}
