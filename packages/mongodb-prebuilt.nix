{ lib, stdenv, fetchurl, autoPatchelfHook, openssl, curl, zlib }:

# Pre-built MongoDB Community Edition binary for x86_64-linux.
# Avoids source compilation (MongoDB 6.0/7.0 does not build cleanly with
# Binutils 2.44 in nixpkgs 25.05, and requires >20GB temp space).
stdenv.mkDerivation rec {
  pname = "mongodb";
  version = "7.0.12";

  src = fetchurl {
    url = "https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-debian12-${version}.tgz";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    openssl
    curl
    zlib
    stdenv.cc.cc.lib  # libstdc++
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 bin/mongod $out/bin/
    install -m755 bin/mongos $out/bin/ 2>/dev/null || true
    runHook postInstall
  '';

  meta = with lib; {
    description = "MongoDB Community Edition (pre-built binary, SSPL)";
    license = licenses.sspl;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
