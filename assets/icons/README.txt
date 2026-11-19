Mindtiq — Acid Pop brand kit
icon/           app icon (lime, dark, monochrome), Play Store 512, Android adaptive layers (432px = 108dp @4x), logo lockups
mascot/         Tiq expression sheet + hero
illustrations/  9 in-app illustrations, 1024px, transparent outside the lime disc (show at ~180dp)
store/          Play feature graphic 1024x500, 5 store frames 1080x1920, splash 1080x2400
guide/          colour + type sheet, component samples
developer/      snaptiq_tokens.json (design tokens, mirrored in lib/core/theme),
                res/font Space Grotesk source fonts (SIL Open Font License;
                the app bundles subsets in assets/fonts)
Every image is provided as SVG (editable, scalable) and PNG.

The Compose/Android-View theme files and Inter OTFs from the original kit
were removed: the Flutter app implements the same tokens in lib/core/theme
and ships its own subset Inter fonts.
