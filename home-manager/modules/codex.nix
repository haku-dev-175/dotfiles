# OpenAI Codex CLI.
#
# nixpkgs lags badly here (0.88.0 in the pinned nixpkgs vs 0.153.4 upstream),
# so this pins the published npm tarball instead. Upstream ships prebuilt,
# statically linked binaries per platform, so there is nothing to compile and
# no interpreter to patch.
#
# To bump: change `version`, then for each platform run
#   nix store prefetch-file https://registry.npmjs.org/@openai/codex/-/codex-<version>-<npmSuffix>.tgz
# and paste the reported hash.
{ config, pkgs, lib, ... }:

let
  version = "0.153.4";

  # npm publishes one package per platform; each unpacks to a single
  # vendor/<rust target>/ tree that must be kept intact — codex-package.json
  # points the binary at its sibling codex-path/ and codex-resources/ dirs.
  platforms = {
    x86_64-linux = {
      npmSuffix = "linux-x64";
      target = "x86_64-unknown-linux-musl";
      hash = "sha256-VIGMufzjNgzG5Ez8WpaVLNXBJD77Q8vkiOEd2oRmPgg=";
    };
    aarch64-darwin = {
      npmSuffix = "darwin-arm64";
      target = "aarch64-apple-darwin";
      hash = "sha256-U10wG0kTGr/aMmT5WfsN76QLvDBpdtmN28FcQkY2xVw=";
    };
  };

  system = pkgs.stdenv.hostPlatform.system;
  platform =
    platforms.${system}
      or (throw "codex.nix: no codex tarball pinned for system ${system}");

  codex = pkgs.stdenvNoCC.mkDerivation {
    pname = "codex";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@openai/codex/-/codex-${version}-${platform.npmSuffix}.tgz";
      inherit (platform) hash;
    };

    # Prebuilt static binaries: no build, and stripping would only risk
    # breaking them.
    dontBuild = true;
    dontStrip = true;
    dontPatchELF = true;

    installPhase = ''
      runHook preInstall

      install -d $out/bin $out/libexec
      cp -R vendor/${platform.target} $out/libexec/codex

      # codex resolves codex-path/ and codex-resources/ relative to the real
      # location of the executable, so a symlink from bin/ is fine.
      ln -s $out/libexec/codex/bin/codex $out/bin/codex

      runHook postInstall
    '';

    meta = {
      description = "OpenAI Codex CLI";
      homepage = "https://developers.openai.com/codex";
      license = lib.licenses.asl20;
      platforms = lib.attrNames platforms;
      mainProgram = "codex";
    };
  };
in
{
  home.packages = [ codex ];
}
