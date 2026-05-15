# Agent Notes

## App Store Shipping

- Use the App Store Connect API key for build/upload lanes:
  `APP_STORE_CONNECT_KEY_PATH`, `APP_STORE_CONNECT_KEY_ID`, and
  `APP_STORE_CONNECT_ISSUER_ID`.
- App Store Connect metadata actions that use `produce` or the privacy upload
  may still require an Apple ID session. Fastlane supports trusted-device codes
  and SMS fallback, not email 2FA. Set `SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER`
  if SMS should be selected automatically.
- Developer Portal team ID and App Store Connect provider/team ID are different
  here. Xcode signing uses `25QMAKVCBN`; Fastlane/App Store Connect uses
  `128577102`.
- `build_app` with `export_options.destination = "upload"` uploads through
  Xcode export. Do not call `upload_to_app_store` after that or Fastlane will
  look for a local IPA that was never exported.
- First App Store submissions need more than a binary: screenshots, privacy URL,
  app privacy answers, age rating, primary category, pricing, review contact,
  IDFA/export-compliance answers, and an attached processed build.
- Fastlane 2.234.0 `price_tier` uses Apple’s old app pricing relationships
  (`apps.prices`, `apps.availableTerritories`, `availableInNewTerritories`) and
  fails against the current API. Set free pricing separately with:
  `applship price free --bundle-id com.zeulewan.nbackmath --territory USA`.
- The preferred privacy URL is served by GitHub Pages from `main`, but Pages can
  sit in `building` and keep returning the old site for several minutes. If an
  App Store submission is blocked, use the public GitHub file URL as a fallback:
  `https://github.com/zeulewan/n-back-math/blob/main/privacy.html`.
- App privacy details are tracked in
  `fastlane/metadata/app_privacy_details.json`. N-Back Math declares
  `DATA_NOT_COLLECTED`.
- Age rating answers are tracked in `fastlane/metadata/rating_config.json`.
  This app declares no restricted content, no ads, no user-generated content,
  no chat, no tracking, and no unrestricted web access.
- Required App Store screenshots are generated from `assets/screenshot.png` with
  `npm run generate:screenshots`. The current targets are iPhone 6.5-inch
  landscape (`2688x1242`) and iPad Pro 12.9-inch landscape (`2732x2048`).
- The iOS app icon is generated with `npm run generate:icon` and writes
  `ios/App/App/Assets.xcassets/AppIcon.appiconset/AppIcon-512@2x.png`.
- Bump `CURRENT_PROJECT_VERSION` before re-uploading the same marketing version;
  Apple rejects duplicate build numbers.
