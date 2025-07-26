{ inputs }:
final: prev: {
  rhodium-fonts = prev.stdenv.mkDerivation rec {
    pname = "rhodium-fonts";
    version = "1.0";

    # _fontBuildData has been moved into the 'let' binding within buildPhase
    # to prevent it from being exposed as a top-level attribute of the derivation.

    dontUnpack = true;

    nativeBuildInputs = with prev; [
      python3
      fontforge
    ];

    nerd-fonts-src = prev.fetchFromGitHub {
      owner = "ryanoasis";
      repo = "nerd-fonts";
      rev = "v3.1.1";
      sha256 = "1dl8xj3w0d2risww8smw8j1w7mq3iy6p1csq00s8iwx15b9phpiz";
    };

    buildPhase =
      let
        # Moved _fontBuildData here to scope it locally to the buildPhase
        _fontBuildData = {
          jetbrains = {
            source = prev.fetchFromGitHub {
              owner = "JetBrains";
              repo = "JetBrainsMono";
              rev = "v2.304";
              sha256 = "sha256-Mw6+9nH3eBfURjSWCKPHXsZKIX8qo9AuTLYRu2Xc5z4=";
            };
            fonts = {
              "fonts/ttf/JetBrainsMono-Bold.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
              "fonts/ttf/JetBrainsMono-BoldItalic.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
              "fonts/ttf/JetBrainsMono-ExtraBold.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
              "fonts/ttf/JetBrainsMono-ExtraBoldItalic.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
              "fonts/ttf/JetBrainsMono-ExtraLight.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
              "fonts/ttf/JetBrainsMono-ExtraLightItalic.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
              "fonts/ttf/JetBrainsMono-Italic.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
              "fonts/ttf/JetBrainsMono-Light.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
              "fonts/ttf/JetBrainsMono-LightItalic.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
              "fonts/ttf/JetBrainsMono-Medium.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
              "fonts/ttf/JetBrainsMono-MediumItalic.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
              "fonts/ttf/JetBrainsMono-Regular.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
              "fonts/ttf/JetBrainsMono-SemiBold.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
              "fonts/ttf/JetBrainsMono-SemiBoldItalic.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
              "fonts/ttf/JetBrainsMono-Thin.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
              "fonts/ttf/JetBrainsMono-ThinItalic.ttf" = {
                patch = true;
                mono = false;
                nonprop = true;
              };
            };
          };
        };
      in
      ''
        runHook preBuild
        cp -r ${nerd-fonts-src} nerd-fonts
        chmod -R +w nerd-fonts

        mkdir -p patched-mono patched-nonprop

        # Process all font sources
        ${
          prev.lib.concatStringsSep "\n" (
            prev.lib.mapAttrsToList (familyName: familyConfig: ''
              echo "Processing ${familyName} fonts..."
              mkdir -p ${familyName}

              # Copy fonts from source
              ${prev.lib.concatStringsSep "\n" (
                prev.lib.mapAttrsToList (fontFile: fontConfig: ''
                  cp "${familyConfig.source}/${fontFile}" "${familyName}/${fontFile}" || true
                '') familyConfig.fonts
              )}

              # Patch fonts that need patching
              ${prev.lib.concatStringsSep "\n" (
                prev.lib.mapAttrsToList (
                  fontFile: fontConfig:
                  prev.lib.optionalString fontConfig.patch ''
                    if [ -f "${familyName}/${fontFile}" ]; then
                      echo "Patching ${fontFile}..."

                      ${prev.lib.optionalString fontConfig.mono ''
                        python3 nerd-fonts/font-patcher \
                          "${familyName}/${fontFile}" \
                          --complete \
                          --careful \
                          --progressbars \
                          --outputdir patched-mono \
                          --makegroups 4 \
                          -s \
                          --adjust-line-height || exit 1
                      ''}

                      ${prev.lib.optionalString fontConfig.nonprop ''
                        python3 nerd-fonts/font-patcher \
                          "${familyName}/${fontFile}" \
                          --complete \
                          --careful \
                          --progressbars \
                          --outputdir patched-nonprop \
                          --makegroups 4 \
                          --adjust-line-height || exit 1
                      ''}
                    fi
                  ''
                ) familyConfig.fonts
              )}
            '') _fontBuildData
          )
        } # This now refers to the _fontBuildData in the 'let' block

        runHook postBuild
      '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/fonts/{opentype,truetype}

      # Install original fonts
      find . -name "*.otf" -not -path "./patched-*/*" -not -path "./nerd-fonts/*" \
        -exec install -Dm644 {} $out/share/fonts/opentype/{} \;
      find . -name "*.ttf" -not -path "./patched-*/*" -not -path "./nerd-fonts/*" \
        -exec install -Dm644 {} $out/share/fonts/truetype/{} \;

      # Install patched fonts
      for dir in patched-mono patched-nonprop; do
        if [ -d "$dir" ]; then
          find "$dir" -name "*.otf" -exec install -Dm644 {} $out/share/fonts/opentype/{} \;
          find "$dir" -name "*.ttf" -exec install -Dm644 {} $out/share/fonts/truetype/{} \;
        fi
      done

      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "JetBrains Mono fonts with selective Nerd Fonts patching for Rhodium";
      platforms = platforms.all;
    };
  };
}
