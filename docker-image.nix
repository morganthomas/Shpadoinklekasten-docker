{ chan ? "e1843646b04fb564abf6330a9432a76df3269d2f"
, pkgs ? import
    (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${chan}.tar.gz";
    })
    {}
, client-src ? pkgs.fetchFromGitHub {
    owner = "morganthomas";
    repo = "Shpadoinklekasten-client";
    rev = "f168bcd6b5cb01d7007f97b6a1f8cc4b0138c14e";
    sha256 = "122pd7z5jdk5yk1d0l6v04ijk8rcrhxsz428w5f0kl80230i195j";
  }
, server-src ? pkgs.fetchFromGitHub {
    owner = "morganthomas";
    repo = "Shpadoinklekasten-server";
    rev = "eaa9b7e653c14b1f9d46f95c1c8faf1b2b4f74a6";
    sha256 = "0y17p7h98lc9yrrkr6p7654gzhqy6pnknrlrr5n6rzihni0s4xzl";
  }
}:
let
  client = import client-src { inherit chan; isJS = true; };

  server = import server-src { inherit chan; };

  startScript = pkgs.writeScriptBin "start-sequence" ''
    mkdir /tmp
    mkdir /app
    cd /app
    ln -s ${client.outPath}/bin/client.jsexe assets
    ls -l assets
    ls assets
    echo "starting server"
    ${server.outPath}/bin/server
  '';
in
pkgs.dockerTools.buildLayeredImage {
  name     = "s11kasten";
  tag      = "latest";
  created  = "now";
  contents = [ pkgs.bash
               pkgs.openssh
               pkgs.cacert
               pkgs.coreutils
               pkgs.procps
               pkgs.curl
               pkgs.nettools
               pkgs.which
               pkgs.iana-etc
             ];
  config = {
    Cmd = [ "${pkgs.bash}/bin/bash" "${startScript}/bin/start-sequence" ];
  };
}
