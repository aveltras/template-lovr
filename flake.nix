{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      overlays = [
        (final: prev: {
          lovr = prev.callPackage (
            { stdenv,
              lib,
              fetchFromGitHub,
              cmake,
              curl,
              luajit,
              openxr-loader,
              pkg-config,
              python3,
              xorg,
            }:

            stdenv.mkDerivation rec {
              pname = "lovr";
              version = "unstable-b46c49c4d158a4d3dab82ef850c0045e6824f8e2";

              src = fetchFromGitHub {
                name = "lovr";
                owner = "bjornbytes";
                repo = "lovr";
                fetchSubmodules = true;
                rev = "b46c49c4d158a4d3dab82ef850c0045e6824f8e2";
                hash = "sha256-KjwXV2IOh38SW5WWCUrkO+Amwv38ONV8N41ZrSZZT7o=";
              };

              nativeBuildInputs = [
                cmake
                pkg-config
              ];

              buildInputs = [
                curl
                luajit
                openxr-loader
                python3
                xorg.libX11
                xorg.libXcursor
                xorg.libXi
                xorg.libXinerama
                xorg.libXrandr
              ];

              cmakeFlags = [
                (lib.cmakeBool "LOVR_SYSTEM_LUA" true)
                (lib.cmakeOptionType "path" "FETCHCONTENT_SOURCE_DIR_JOLTPHYSICS" "${fetchFromGitHub {
                  name = "JoltPhysics";
                  owner = "jrouwe";
                  repo = "JoltPhysics";
                  fetchSubmodules = true;
                  tag = "v5.3.0";
                  hash = "sha256-Vh4SLRyA9EtYCaulA7kI3CtCioJvEoSyuAXZJmDRTB8=";
                }}")
              ];

              dontStrip = true; # prevents stripping the fused archive needed for cli to work normally

              installPhase = ''
                runHook preInstall
                mkdir -p $out/bin $out/lib
                cp -r bin/lovr $out/bin/
                cp -r bin/*.so $out/lib/
                runHook postInstall
              '';
            }
          ) { };

        })
      ];
      pkgs = import nixpkgs { inherit system overlays; };
    in {
      devShells.${system}.default = pkgs.mkShell
        rec {
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

          LOVR_DEFS = pkgs.fetchFromGitHub {
            owner = "LuaCATS";
            repo = "lovr";
            rev = "3aa8c53b100b9d04e6b26aa00f9926eeebbf5cae";
            hash = "sha256-X5SSta9m5hgFH9HUq+j17R1JuYkk1EXB28+LGoeAgyw=";
          };

          buildInputs = with pkgs; [
            glfw
            lovr
            lua-language-server
            openxr-loader
            pulseaudio
            vulkan-loader
          ];
        };
    };
}
