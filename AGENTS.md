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
  `https://github.com/zeulewan/n-back-math/blob/main/apps/web/privacy.html`.
- App privacy details are tracked in
  `fastlane/metadata/app_privacy_details.json`. N-Back Math declares
  `DATA_NOT_COLLECTED`.
- Age rating answers are tracked in `fastlane/metadata/rating_config.json`.
  This app declares no restricted content, no ads, no user-generated content,
  no chat, no tracking, and no unrestricted web access.
- Required App Store screenshots are generated with
  `npm run generate:screenshots`. The script builds the native SwiftUI app for
  Simulator, launches it on an iPhone and iPad simulator, and writes PNG files
  to `fastlane/screenshots/en-US`. It does not upload anything.
- The browser app lives in `apps/web`; `npm run build:web` writes the GitHub
  Pages artifact to `dist`.
- The iOS app is native SwiftUI under `apps/ios/NBackMath`; `ios/App` only
  contains the Xcode project, signing metadata, assets, and launch screen.
- Do not run `fastlane ios upload`, `fastlane ios submit`, or
  `fastlane ios ship` until screenshots have been generated and reviewed.
- Screenshot-only metadata fixes can be uploaded with
  `fastlane ios screenshots`; this lane skips binary upload, skips text
  metadata, edits the live version instead of creating a duplicate version,
  disables Fastlane precheck, does not submit for review, and overwrites
  screenshots from `fastlane/screenshots`.
- The iOS app icon is generated with `npm run generate:icon` and writes
  `ios/App/App/Assets.xcassets/AppIcon.appiconset/AppIcon-512@2x.png`.
- Bump `CURRENT_PROJECT_VERSION` before re-uploading the same marketing version;
  Apple rejects duplicate build numbers.
- A version can be `READY_FOR_SALE` while EU storefronts are still blocked by
  DSA trader status. Check availability with:
  `applship api get '/v2/appAvailabilities/APP_ID/territoryAvailabilities?limit=200'`.
  For N-Back Math, App Store Connect showed 148 territories as `AVAILABLE` and
  the 27 EU territories as `TRADER_STATUS_NOT_PROVIDED` on 2026-05-18.
- DSA trader status is account/app compliance, not binary review. Apple’s docs
  say the Account Holder/Admin must declare trader status in App Store Connect,
  and Apple says it can’t decide trader status for the developer. If not
  distributing in the EU, the app is not acting as a trader on the App Store.
