final: prev:
{
  estelle = prev.stdenvNoCC.mkDerivation rec {
    pname = "estelle";
    version = "0.4.6";

    src = prev.fetchurl {
      url = "https://github.com/uqeu/estelle-cli/releases/download/v${version}/estelle-aarch64-apple-darwin.tar.gz";
      sha256 = "e3f6af92f1bd4c7e93fdca13341486bd8dfafe1343854de799c32176099f119b";
    };

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      tar -xzf "$src" -C "$out/bin" estelle
      chmod 755 "$out/bin/estelle"
      runHook postInstall
    '';

    meta = {
      description = "Repository memory and code intelligence for coding agents";
      homepage = "https://github.com/uqeu/estelle-cli";
      sourceProvenance = [ prev.lib.sourceTypes.binaryNativeCode ];
      platforms = [ "aarch64-darwin" ];
      mainProgram = "estelle";
    };
  };
}
