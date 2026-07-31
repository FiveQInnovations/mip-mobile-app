# Form browser handoff testing plan

Baseline captured and fixes verified July 30, 2026. The intended user
experience is the same for every form journey: selecting the form leaves the
app and opens a usable website form in the system browser. The apps do not
submit these forms inside their WebViews, which avoids native CSRF and session
handling.

## Form inventory

| Journey | Source in the app | Browser destination |
| --- | --- | --- |
| Contact Form | Contact Us page | `/about/contact-us#contact-form-response` |
| Prayer Request | Contact Us shortcut | `/prayer-request` |
| Chaplain Request | Search | `/chaplain-request` |
| Membership Form | Become a Member page | `firefightersforchrist.churchsuite.com/embed/addressbook/form` |
| Contact Us to Start a Chapter | Start a Chapter hero | `/chapters/start-a-chapter#start-a-chapter-online-form-response` |
| Start a Chapter Form | Start a Chapter page | `/chapters/start-a-chapter#start-a-chapter-online-form-response` |

The CMS is covered indirectly: the API contract tests render the real local
Kirby content, including form blocks and link-to pages, before the device tests
exercise those responses.

## iOS

The behavior-named XCUI cases live in
`ios-mip-app/FFCIUITests/FFCIUITests.swift`:

- `testTappingContactFormOnContactUsOpensSafari`
- `testTappingPrayerRequestOnContactUsOpensSafari`
- `testSelectingChaplainRequestFromSearchOpensSafari`
- `testTappingMembershipFormOpensSafari`
- `testTappingContactUsToStartAChapterOpensSafari`
- `testTappingStartAChapterFormOpensSafari`

The original production baseline proved that the Prayer Request shortcut
opened an empty in-app page and that Chaplain Request search did not hand off
to Safari. Some initial Contact and Start a Chapter failures were test-harness
false negatives caused by XCUI reporting offscreen WebView links as hittable;
the tests now scroll controls into the visible safe area before tapping.

All six cases pass against the fixed local API:

```sh
cd ios-mip-app
xcodebuild test \
  -project FFCI.xcodeproj \
  -scheme FFCI \
  -destination 'id=0CFBE144-D9CC-4887-8B51-EDE9013AE912' \
  -only-testing:FFCIUITests/FFCIUITests/testTappingContactFormOnContactUsOpensSafari \
  -only-testing:FFCIUITests/FFCIUITests/testTappingPrayerRequestOnContactUsOpensSafari \
  -only-testing:FFCIUITests/FFCIUITests/testSelectingChaplainRequestFromSearchOpensSafari \
  -only-testing:FFCIUITests/FFCIUITests/testTappingMembershipFormOpensSafari \
  -only-testing:FFCIUITests/FFCIUITests/testTappingContactUsToStartAChapterOpensSafari \
  -only-testing:FFCIUITests/FFCIUITests/testTappingStartAChapterFormOpensSafari
```

The launch helper supplies the local debug API override. The DDEV root CA must
be trusted by the booted simulator:

```sh
xcrun simctl keychain booted add-root-cert \
  "$HOME/Library/Application Support/mkcert/rootCA.pem"
```

Final result bundle:
`ios-mip-app/build-ui-tests/form-navigation-2026-07-30/FFCILocalFixedFormNavigationFinal4-2026-07-30.xcresult`.

The production-configured Release scheme also builds successfully.

## Android

The behavior-named instrumented cases live in
`android-mip-app/app/src/androidTest/java/com/fiveq/ffci/FormBrowserHandoffTest.kt`:

- `tappingContactFormOnContactUsOpensTheWebsiteInTheBrowser`
- `tappingPrayerRequestOnContactUsOpensTheWebsiteInTheBrowser`
- `selectingChaplainRequestFromSearchOpensTheWebsiteInTheBrowser`
- `tappingMembershipFormOpensTheWebsiteInTheBrowser`
- `tappingContactUsToStartAChapterOpensTheWebsiteInTheBrowser`
- `tappingStartAChapterFormOpensTheWebsiteInTheBrowser`

The original production baseline reproduced the empty Prayer Request page.
The expanded suite then exposed a separate real defect: links with
`target="_blank"`, including Contact and the third-party Membership form,
bypassed Android's WebView navigation callback. The renderer now normalizes
browser-bound anchors so the existing callback can open Chrome.

All six cases pass against the fixed local API:

```sh
cd android-mip-app
./gradlew :app:connectedDebugAndroidTest \
  -PffciApiBaseUrlOverride=http://10.0.2.2:55012 \
  -Pandroid.testInstrumentationRunnerArguments.class=com.fiveq.ffci.FormBrowserHandoffTest
```

The HTML report is
`android-mip-app/app/build/reports/androidTests/connected/debug/index.html`.
Both production-configured artifacts also build successfully:

```sh
./gradlew :app:assembleDebug :app:assembleRelease
```

The API override and cleartext permission exist only in debug builds; Release
always uses the bundled HTTPS production API.

## API and CMS content

The deployed-contract cases live in
`tests/LiveFormNavigationTest.php` in the `wsp-mobile` plugin repository:

- `testContactFormButtonOpensThePublicContactPage`
- `testMembershipFormOpensTheMembershipWebsite`
- `testPrayerRequestShortcutOpensThePublicPrayerRequestPage`
- `testChaplainRequestFromSearchOpensThePublicChaplainRequestPage`
- `testStartAChapterFormOpensThePublicStartAChapterPage`

Run against the local fixed Kirby site:

```sh
WSP_MOBILE_API_BASE_URL=https://ws-ffci.ddev.site:55013 \
WSP_MOBILE_API_KEY=... \
vendor/bin/phpunit --group live --testdox
```

Run the deterministic plugin suite separately:

```sh
vendor/bin/phpunit --exclude-group live --testdox
```

The local fix makes form search results point to public landing pages, adds an
optional `navigation: { behavior: "external", url: ... }` contract for
browser-only pages, teaches both apps to honor that contract from search or
direct page navigation, transforms link-to pages consistently, and corrects
the Prayer Request CMS destination to `/prayer-request`.

## Release and production verification

The API change adds an optional response field, so the plugin's versioning
rules classify its first release as the next backward-compatible minor version
(`v1.1.0`, after review and commit). The site is currently documented as
pinning `1.0.*`, so its Composer constraint must intentionally move to `1.1.*`
when the API is released.

Release in this order:

1. Review, commit, tag, and deploy the `wsp-mobile` API/CMS changes.
2. Run the seven live contract tests against
   `https://firefightersforchrist.org`.
3. Build and distribute the iOS and Android changes.
4. Run the six device tests on each platform again with the production API override removed.

The work is ready for that release sequence when:

- all seven API contract cases pass against production;
- all six iOS cases pass against production;
- all six Android cases pass against production;
- the ordinary API suite and both Release builds remain green; and
- neither search nor a CMS link-to shortcut can produce an empty native page.
