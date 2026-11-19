# Mindtiq brand prompt kit

Prompts for generating Mindtiq's brand images with an image model
(Midjourney, ChatGPT / DALL·E, Ideogram, Firefly, Flux). Each prompt starts
from the same style block so every asset looks like one family.

## Brand foundation (read once, reuse everywhere)

- **Name:** Mindtiq. "Snap" (a screenshot) + "-tiq" (smart, as in logic or
  boutique). Smart screenshots.
- **Promise:** Screenshot anything. Find everything. Turn it into action.
  Private: everything runs on the phone.
- **Personality:** calm, clever, trustworthy, a little playful. Never loud,
  never techy-cold.
- **Logo mark:** four rounded viewfinder corners framing a small lightning
  spark, white on a rounded square.
- **Colours:**
  - Primary violet `#635BFF` to purple `#8B5CF6` (diagonal gradient)
  - Accent teal `#14B8A6`
  - Ink `#111827`, soft background `#F5F6FA`
  - Dark mode background `#0F1117`
- **Type:** Inter (SemiBold for headings, Regular for body).
- **Shapes:** generous rounded corners (about 28% of size), soft shadows,
  lots of white space, flat vector with a subtle gradient.

## 1. Style block (prefix for every prompt)

```
Modern minimal flat vector illustration for a privacy-first productivity app
named Mindtiq. Brand palette: violet #635BFF to purple #8B5CF6 gradient,
accent teal #14B8A6, ink #111827, soft off-white #F5F6FA. Rounded geometric
shapes, soft subtle shadows, clean negative space, gentle depth, crisp
edges, premium and friendly, consistent line weight, no clutter.
```

**Negative prompt / avoid** (add where the tool supports it):

```
photorealistic, 3D render clutter, harsh neon, gradients outside the brand
palette, text artifacts, watermark, extra fingers, busy background, drop
shadows that look dirty, generic stock-photo look, cloud icons, other
brands' logos
```

## 2. Mascot: "Tiq"

Create the character sheet first, then reuse it as a reference image for
every other pose. Keep the same seed or character reference.

```
[STYLE BLOCK] Character design sheet of "Tiq", the Mindtiq mascot: a small,
round, softly glowing spark creature in the violet-to-purple brand gradient,
with a tiny white lightning-bolt mark on its forehead, big friendly oval
eyes, a small smile, and two little rounded "viewfinder bracket" arms like
the corners of a camera frame. Cute but smart, curious, calm. Show front
view, three-quarter view, side view, and three expressions (happy, curious,
proud). White background, flat vector, consistent proportions, no text.
```

Poses for app screens (one image each, transparent or #F5F6FA background):

| Use in the app | Prompt ending |
| --- | --- |
| Onboarding 1 (welcome) | `Tiq waving hello, floating above a neat stack of phone screenshots that sort themselves into folders.` |
| Onboarding 2 (privacy) | `Tiq holding a small teal shield in front of a phone, a closed padlock nearby, conveying "everything stays on your device".` |
| Onboarding 3 (actions) | `Tiq tapping a glowing button that turns a screenshot into a calendar event, a reminder bell and a map pin.` |
| Empty library | `Tiq sitting on an empty photo frame, looking hopeful, a small "+" sparkle next to it.` |
| No search results | `Tiq holding a magnifying glass, puzzled, small question-mark sparkles.` |
| No reminders | `Tiq napping peacefully on a crescent-shaped alarm clock.` |
| All done / reviewed | `Tiq celebrating with confetti in brand colours, a checkmark badge.` |
| Error / try again | `Tiq gently fixing a loose puzzle piece with a tiny wrench, calm expression.` |
| Import in progress | `Tiq carrying a screenshot like a small flag, mid-stride, motion lines.` |

Export at 1024×1024 or larger; the app shows them at about 180 dp.

## 3. App icon (refinement of the current mark)

```
[STYLE BLOCK] App icon for Mindtiq: a rounded-square with a smooth diagonal
gradient from #635BFF (top-left) to #8B5CF6 (bottom-right). Centered white
symbol: four thick rounded viewfinder corner brackets framing a small,
crisp lightning spark. Subtle inner glow, very soft long shadow, perfectly
centered, generous padding, readable at 48 px. Flat vector, no text,
1024x1024.
```

Variants to request: "monochrome white symbol on transparent background"
(Android themed icon / notification icon) and "dark mode version on #0F1117
with the gradient only on the symbol".

## 4. Google Play feature graphic (1024 × 500)

```
[STYLE BLOCK] Wide banner 1024x500 for the Google Play listing of Mindtiq.
Left third: the Mindtiq app icon and the wordmark "Mindtiq" in Inter
SemiBold, with the tagline "Screenshot anything. Find everything."
Right two-thirds: a tilted modern Android phone showing a clean dashboard of
organised screenshots (receipts, a boarding pass, a recipe) with small
floating chips for "Add to calendar", "Remind me", "Show on map". Tiq the
mascot peeks from behind the phone. Soft violet gradient background with
subtle rounded shapes. Lots of breathing room.
```

Image models often misspell text. Generate without text, then add the
wordmark and tagline yourself in Figma or Canva using Inter.

## 5. Store screenshot frames (1080 × 1920)

Use real app screenshots inside these frames; generate only the background
and frame.

```
[STYLE BLOCK] Vertical marketing frame 1080x1920: soft off-white background
with a faint violet gradient glow at the top, a large rounded area for a
phone screenshot in the centre-bottom, and empty space at the top for a
two-line headline. Small decorative brand shapes (rounded squares, sparks)
in the corners. No text, no phone content.
```

Suggested headlines for the five frames:

1. Screenshot anything. Find everything.
2. Dates, amounts and links, found for you.
3. One tap to your calendar, maps or contacts.
4. Search the text inside every screenshot.
5. Private by design. Nothing leaves your phone.

## 6. Social and launch banners

| Asset | Size | Prompt ending |
| --- | --- | --- |
| X / Twitter header | 1500×500 | `Panoramic banner, Tiq floating among sorted screenshot cards that connect with thin lines to small calendar, map and bell icons. Leave the left 35% calm for profile photo overlap.` |
| LinkedIn banner | 1584×396 | `Ultra-wide, minimal: a row of screenshot cards transforming left-to-right into tidy action chips, ending with Tiq giving a thumbs up.` |
| Product Hunt gallery | 1270×760 | `Hero scene: phone with the Mindtiq dashboard, floating action chips, Tiq waving, headline space on the left.` |
| Open Graph / link preview | 1200×630 | `Centered app icon with soft glow, Tiq beside it, generous margins for a title.` |

## 7. Splash and in-app accents

```
[STYLE BLOCK] Minimal splash artwork: the Mindtiq symbol (viewfinder
corners with a spark) centered on a smooth violet-to-purple gradient, a
very soft radial glow behind it, nothing else. 1242x2688, no text.
```

```
[STYLE BLOCK] Set of 12 small spot icons in one consistent style, 2px
rounded strokes in #635BFF with teal #14B8A6 highlights, on transparent
background: receipt, boarding pass, calendar, bell, map pin, Wi-Fi, link,
phone, envelope, shopping bag, recipe card, code brackets.
```

## Tool notes

- **Midjourney:** paste the prompt, then add `--ar 1:1` (icons, mascot),
  `--ar 205:100` (feature graphic), `--ar 9:16` (screen frames),
  `--style raw --stylize 100`. For mascot poses, add `--cref <URL of the
  character sheet> --cw 100`.
- **ChatGPT / DALL·E:** start with "Use exactly this style:" followed by the
  style block. Upload the character sheet and say "keep this exact
  character" for each new pose.
- **Ideogram:** best when the image itself must contain the word "Mindtiq";
  quote the text exactly.
- **Final files:** vectorise the icon and mascot (Illustrator Image Trace,
  or Vectorizer.ai) so they stay sharp. Keep the app's existing launcher
  icon until a new one is final, then regenerate the Android sizes with the
  script used for the current icon.
