{
  inputs,
  cell,
}: let
  inherit (inputs) self std nixpkgs;
  inherit (nixpkgs) rustPlatform;
  cargo = builtins.fromTOML (builtins.readFile (self + "/Cargo.toml"));
in {
  default = rustPlatform.buildRustPackage {
    pname = cargo.package.name;
    version = cargo.package.version;

    src = std.incl self [
      "Cargo.toml"
      "Cargo.lock"
      "src"
      "res"
    ];

    cargoLock = {
      lockFile = self + "/Cargo.lock";
      outputHashes."hyprland-0.4.0-alpha.2" = "sha256-bvjvN3vi82Ys3zqY1mqYxRjbUwwcqZ6b0X3aF8Wb2Is=";
    };

    nativeBuildInputs = with nixpkgs; [
      pkg-config
      makeWrapper
    ];

    buildInputs = with nixpkgs; [
      fontconfig
      libxkbcommon
      wayland
      vulkan-loader
      libGL
    ];

    postFixup = ''
      patchelf --add-rpath ${nixpkgs.vulkan-loader}/lib $out/bin/watershot
      patchelf --add-rpath ${nixpkgs.libGL}/lib $out/bin/watershot

      wrapProgram $out/bin/watershot \
        --add-flags "-g \"${nixpkgs.grim}/bin/grim\""
    '';
  };
}
