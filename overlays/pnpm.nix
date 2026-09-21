# Pin pnpm to an exact version, independent of what nixpkgs ships.
#
# This overlay builds the published npm tarball directly.
#
# It exposes ONLY `pnpm-pinned`, and deliberately shadows no nixpkgs attribute.
# Both `pkgs.pnpm` and the versioned `pkgs.pnpm_*` attrs are real packages that
# other derivations build against (prettier does `pnpm = pnpm_11`), and they
# consume passthru this derivation does not provide — `pnpm.nodejs-slim`,
# `pnpm.fetchDeps`, `pnpm.configHook`. Overriding any of those names breaks
# those builds. Reference `pnpm-pinned` from package lists instead; it still
# installs `pnpm`/`pnpx`/`pn`/`pnx` into the profile, so PATH is unchanged.
#
# As of nixpkgs 2026-09 upstream carries pnpm 12.3.4 (`pnpm`) and 11.27.0
# (`pnpm_11`), so this overlay is now only about holding an exact version
# rather than about nixpkgs lagging. Drop it if the exact pin stops mattering.
#
# To bump: change `version`, then run
#   nix store prefetch-file https://registry.npmjs.org/pnpm/-/pnpm-<version>.tgz
# and paste the reported hash below.
final: prev:

let
  version = "11.22.0";
  hash = "sha256-V6l+byOj+v/AMVOk74x3CgVSYSuGQK6+Ob/dV1TQ69w=";

  pnpm = prev.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "pnpm";
    inherit version;

    src = prev.fetchurl {
      url = "https://registry.npmjs.org/pnpm/-/pnpm-${finalAttrs.version}.tgz";
      inherit hash;
    };

    nativeBuildInputs = [
      prev.installShellFiles
      prev.nodejs
    ];

    # Strip the prebuilt binaries: the reflink bindings only ship for darwin and
    # windows (pnpm already falls back to plain copies without them, which is
    # what upstream does on Linux anyway), and the fastlist vendor binaries are
    # Windows-only. Keeps the output free of foreign native code.
    preConfigure = ''
      find . \( -name '*.node' -o -name '*.exe' \) -delete
    '';

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -d $out/bin $out/libexec
      cp -R . $out/libexec/pnpm

      ln -s $out/libexec/pnpm/bin/pnpm.mjs $out/bin/pnpm
      ln -s $out/libexec/pnpm/bin/pnpx.mjs $out/bin/pnpx
      # Upstream also exposes these short aliases.
      ln -s $out/libexec/pnpm/bin/pnpm.mjs $out/bin/pn
      ln -s $out/libexec/pnpm/bin/pnpx.mjs $out/bin/pnx

      runHook postInstall
    '';

    postInstall = ''
      patchShebangs $out/libexec/pnpm/bin

      export HOME=$(mktemp -d)
      node $out/bin/pnpm completion bash >pnpm.bash
      node $out/bin/pnpm completion fish >pnpm.fish
      node $out/bin/pnpm completion zsh >pnpm.zsh
      sed -i '1 i#compdef pnpm' pnpm.zsh
      installShellCompletion pnpm.{bash,fish,zsh}
    '';

    passthru.tests.version = prev.testers.testVersion {
      package = finalAttrs.finalPackage;
    };

    meta = {
      description = "Fast, disk space efficient package manager for JavaScript";
      homepage = "https://pnpm.io/";
      changelog = "https://github.com/pnpm/pnpm/releases/tag/v${version}";
      license = prev.lib.licenses.mit;
      platforms = prev.lib.platforms.all;
      mainProgram = "pnpm";
    };
  });
in
{
  pnpm-pinned = pnpm;
}
