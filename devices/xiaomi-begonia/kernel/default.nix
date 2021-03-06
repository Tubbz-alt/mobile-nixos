{
  mobile-nixos
, fetchFromGitHub
, buildPackages
}:

#
# Some notes:
#
#  * https://github.com/MiCode/Xiaomi_Kernel_OpenSource/wiki/How-to-compile-kernel-standalone
#
# Things to note:
#
# Either gcc49 or clang is needed for this kernel to build.
#

let
  # The "main" CFW kernel repository
  src = fetchFromGitHub {
    owner = "AgentFabulous";
    repo = "begonia";
    rev = "186e9186f6fca7ca5aec11a0d967f5c525d56539";
    sha256 = "1p08392pcavfjy5i0zc61dxibr0jq9kb3na1hdx85q0z3d9sfwp6";
  };

  dtc_overlay = buildPackages.writeShellScript "dtc_overlay" ''
    exec ${buildPackages.dtc}/bin/dtc "$@"
  '';
in
  
mobile-nixos.kernel-builder-clang_9 {
  version = "4.14.184";
  configfile = ./config.aarch64;

  inherit src;

  patches = [
    ./0001-mtkfb-Default-to-RGB-order.patch
    ./0001-fix-teei-mediatek.patch
    ./0001-center-logo.patch
    ./0001-mt6360-white-led-defaults-to-on.patch
    ./0003-arch-arm64-Add-config-option-to-fix-bootloader-cmdli.patch
  ];

  isImageGzDtb = true;
  isModular = false;

  postPatch = ''
    echo ":: Replacing dtc_overaly"
    (PS4=" $ "; set -x
    rm scripts/dtc/dtc_overlay
    cp ${dtc_overlay} scripts/dtc/dtc_overlay
    )
  '';
}
