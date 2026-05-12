# Flutter App Structure

## Project name

Suggested package/app name during development:

```text
settle_this
```

Potential bundle IDs:

```text
com.athletedomains.settlethis
com.athletedomains.settlethisapp
```

## Folder structure

```text
lib/
  main.dart
  firebase_options.dart

  app/
    settle_this_app.dart
    router.dart
    theme.dart
    constants.dart

  core/
    config/
      remote_config_service.dart
    errors/
      app_error.dart
      error_mapper.dart
    services/
      analytics_service.dart
      crashlytics_service.dart
      share_service.dart
    utils/
      date_utils.dart
      validators.dart

  features/
    auth/
      data/
        auth_repository.dart
      presentation/
        auth_gate.dart
        sign_in_screen.dart

    onboarding/
      presentation/
        onboarding_screen.dart
        age_gate_screen.dart
        disclaimer_screen.dart

    submit_case/
      data/
        verdict_repository.dart
      domain/
        dispute_case_input.dart
        relationship_type.dart
        tone_mode.dart
      presentation/
        submit_case_screen.dart
        side_input_screen.dart
        tone_selector_screen.dart
        review_case_screen.dart

    verdict/
      domain/
        verdict.dart
        verdict_status.dart
      presentation/
        verdict_loading_screen.dart
        verdict_result_screen.dart
        verdict_card_widget.dart
        share_card_preview_screen.dart

    history/
      data/
        history_repository.dart
      presentation/
        history_screen.dart
        case_detail_screen.dart

    paywall/
      data/
        subscription_repository.dart
      presentation/
        paywall_screen.dart
        usage_limit_screen.dart

    settings/
      presentation/
        settings_screen.dart
        privacy_screen.dart
        delete_data_screen.dart

  shared/
    widgets/
      app_button.dart
      app_card.dart
      tone_chip.dart
      verdict_badge.dart
      loading_gavel.dart
      empty_state.dart
    models/
      result.dart
```

## Core packages

Add these to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  firebase_analytics: ^latest
  firebase_crashlytics: ^latest
  firebase_remote_config: ^latest
  flutter_riverpod: ^latest
  go_router: ^latest
  freezed_annotation: ^latest
  json_annotation: ^latest
  share_plus: ^latest
  purchases_flutter: ^latest
  google_fonts: ^latest
  intl: ^latest
  uuid: ^latest

dev_dependencies:
  build_runner: ^latest
  freezed: ^latest
  json_serializable: ^latest
  flutter_lints: ^latest
```

Use actual latest compatible versions when creating the project.

## Navigation routes

```text
/
/onboarding
/age-gate
/disclaimer
/sign-in
/home
/submit
/submit/sides
/submit/tone
/submit/review
/verdict/loading
/verdict/:caseId
/history
/history/:caseId
/paywall
/settings
/settings/privacy
/settings/delete-data
```

## State management

Use Riverpod providers:

```text
authStateProvider
userProfileProvider
remoteConfigProvider
usageProvider
subscriptionProvider
submitCaseControllerProvider
verdictRepositoryProvider
historyRepositoryProvider
analyticsServiceProvider
```

## Main app flow

```text
Open app
  -> Firebase init
  -> Age gate if first launch
  -> Disclaimer if first launch
  -> Auth gate
  -> Home screen
  -> Submit dispute
  -> Review
  -> Cloud Function createVerdict
  -> Loading screen
  -> Verdict result
  -> Share/save/feedback
```

## MVP screens

### HomeScreen

Components:

- App logo/name
- Daily usage counter
- Big “Settle Something” button
- Recent verdicts preview
- Tone/persona preview
- Upgrade card if free user

### SubmitCaseScreen

Fields:

- “What happened?” multiline text
- Relationship type selector
- Optional “My side”
- Optional “Their side”
- Save case toggle

Validation:

- Minimum 30 characters
- Maximum 3000 characters
- Warn against names/addresses

### ToneSelectorScreen

Cards:

- Balanced Referee
- Playful Roast
- Courtroom Judge

Default to Balanced Referee.

### VerdictLoadingScreen

Show fun loading statuses:

- “Reviewing both sides…”
- “Dusting off the tiny gavel…”
- “Checking for household crimes…”
- “Preparing a fair ruling…”

### VerdictResultScreen

Sections:

- Verdict badge
- Summary verdict
- Who was more right
- What you got right
- What they got right
- What was missed
- Practical fix
- Funny final ruling
- Text to send
- Share button
- Save/history button
- Feedback buttons

## UI theme

Suggested palette:

- Background: warm cream/off-white
- Primary: deep navy or dark purple
- Accent: golden yellow/gavel color
- Secondary accent: coral/pink for humor
- Success: green for “resolved”
- Warning: amber for safety redirects

Typography:

- Rounded, friendly sans-serif
- Large bold verdict labels
- Readable body text

Design feel:

- Modern mobile cards
- Soft shadows
- Rounded corners
- Playful icons
- Courtroom-inspired but not legal-serious

## Accessibility

- Large touch targets
- Dark mode later, not MVP if time constrained
- Dynamic font support
- High contrast for verdict text
- No tiny disclaimers only

