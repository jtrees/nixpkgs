{ pkgsi686Linux }:

let
  f =
    { lib
    , stdenv
    , fetchurl
    , dpkg
    , makeWrapper
    , autoPatchelfHook
    , coreutils
    , file
    , gawk
    , ghostscript
    , gnused
    , pkgsi686Linux
    }:

    stdenv.mkDerivation rec {
      pname = "mfc9142cdnlpr";
      version = "1.1.3-0";

      src = fetchurl {
        url = "https://download.brother.com/welcome/dlf101616/${pname}-${version}.i386.deb";
        hash = "sha256-HKEUPAdMM+z+DNwm61xebNmwu+lMEW/JwD1U3nowKd8=";
      };

      unpackPhase = ''
        dpkg-deb -x $src $out
      '';

      nativeBuildInputs = [
        dpkg
        makeWrapper
        autoPatchelfHook
      ];

      dontBuild = true;

      installPhase = ''
        dir=$out/opt/brother/Printers/mfc9142cdn

        wrapProgram $dir/inf/setupPrintcapij \
          --prefix PATH : ${lib.makeBinPath [
            coreutils
          ]}

        substituteInPlace $dir/lpd/filtermfc9142cdn \
          --replace "BR_CFG_PATH=" "BR_CFG_PATH=\"$dir/\" #" \
          --replace "BR_LPD_PATH=" "BR_LPD_PATH=\"$dir/\" #"

        wrapProgram $dir/lpd/filtermfc9142cdn \
          --prefix PATH : ${lib.makeBinPath [
            coreutils
            file
            ghostscript
            gnused
          ]}

        substituteInPlace $dir/lpd/psconvertij2 \
          --replace '`which gs`' "${ghostscript}/bin/gs"

        wrapProgram $dir/lpd/psconvertij2 \
          --prefix PATH : ${lib.makeBinPath [
            gnused
            gawk
          ]}
      '';

      meta = with lib; {
        description = "Brother MFC-9142CDN LPR printer driver";
        homepage = "http://www.brother.com/";
        sourceProvenance = with sourceTypes; [ binaryNativeCode ];
        license = licenses.unfree;
        maintainers = with maintainers; [ jtrees ];
        platforms = [ "i686-linux" "x86_64-linux" ];
      };
    };

in

pkgsi686Linux.callPackage f { }
