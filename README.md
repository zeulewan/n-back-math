# N-Back Math

Mobile-first arithmetic `n-back` trainer. Static web app with a Capacitor iOS
wrapper.

![N-Back Math screenshot](assets/screenshot.png)

Play it on GitHub Pages: https://zeulewan.github.io/n-back-math/

## iPhone App

Build and open the iOS project on a Mac with Xcode:

```sh
npm install
npm run open:ios
```

In Xcode, choose a signing team, then run the `App` target on an iPhone or
simulator. After web changes, run `npm run sync:ios` to copy them into the iOS
project.

## Play

- Use `-` and `+` to change level.
- Press `Start`.
- Answer the problem from `N` steps back.
- Each run is always `24` questions.
- `Slow` gives `4s`; `Fast` gives `3s`.
- Use `Stats` to review saved browser progress.

Progress is stored in browser `localStorage`. Use `Clear Progress` on the
stats page to reset it.
