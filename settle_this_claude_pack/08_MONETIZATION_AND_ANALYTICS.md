# Monetization and Analytics

## Monetization recommendation

Use freemium.

### Free tier

- 3 verdicts per day
- Balanced Referee tone
- Limited share cards with watermark
- Saved history limit, e.g. 10 cases
- Optional ads later, not first build if speed matters

### Plus subscription

- Unlimited verdicts
- All tone modes
- Unlimited saved history
- No ads
- Share card customization
- Try another tone
- Deeper practical advice
- Early access to new judge/persona packs

### One-time IAP later

- Judge packs
- Themed card styles
- Seasonal dispute packs
- Creator/persona packs

## Pricing hypothesis

Start simple:

- Monthly: $4.99 or $5.99
- Annual: $29.99 or $39.99
- Lifetime launch offer optional: $24.99–$49.99

Avoid aggressive weekly trials or confusing billing. The market research specifically warns against dark-pattern subscription design.

## RevenueCat setup

Entitlement:

```text
settle_plus
```

Offerings:

```text
default
  monthly_plus
  annual_plus
  lifetime_plus optional
```

App constants:

```dart
const String entitlementSettlePlus = 'settle_plus';
```

## Usage limit logic

Free user:

```text
if freeVerdictsUsedToday < freeVerdictsPerDay:
  allow
else:
  show usage limit/paywall
```

Plus user:

```text
allow unlimited, but still rate-limit abuse/spam
```

Suggested limits:

- Free: 3/day
- Plus: 100/day soft cap to protect cost
- Anonymous trial: 1–2 total before auth required

## Analytics events

Use Firebase Analytics.

### Onboarding

```text
onboarding_started
age_gate_passed
age_gate_failed
disclaimer_accepted
sign_in_started
sign_in_completed
```

### Verdict funnel

```text
submit_case_started
relationship_type_selected
tone_selected
case_reviewed
create_verdict_started
create_verdict_completed
create_verdict_failed
safety_soft_redirect_shown
safety_block_shown
```

### Engagement

```text
verdict_viewed
verdict_shared
share_card_created
text_to_send_copied
case_saved
case_deleted
history_opened
feedback_submitted
try_another_tone_tapped
settle_another_tapped
```

### Monetization

```text
paywall_viewed
paywall_cta_tapped
purchase_started
purchase_completed
purchase_failed
restore_purchase_tapped
usage_limit_reached
```

## Key metrics

### Activation

- Install to first verdict completion
- Target: >60%

### Completion

- Started case to completed verdict
- Target: >75%

### Share rate

- Verdicts shared / verdicts completed
- Target: 10–20%

### Retention

- D1 retention
- D7 retention target: >15%
- D30 retention

### Repeat use

- Cases per MAU
- Target: 2+ per month

### Paid conversion

- Free to paid conversion
- Target by end of year 1: 2–4%

### Quality

- Helpful vote rate
- Funny vote rate
- Fair vote rate
- Too harsh reports
- Safety intercept rate

## A/B test ideas

### Onboarding copy

A:

```text
Settle silly arguments without starting a bigger one.
```

B:

```text
Who was right? Let the tiny judge decide.
```

### CTA text

A:

```text
Settle Something
```

B:

```text
Get the Verdict
```

### Free tier

A: 3 free verdicts/day
B: 5 free verdicts/day with ads later

### Paywall trigger

A: after usage limit
B: after first shared verdict
C: after user taps “Try Another Tone”

## Do not monetize with these in MVP

- Anonymous public posting
- Paid “see who secretly submitted you” mechanics
- Manipulative clues
- Misleading weekly trials
- AI claims that imply certainty or professional expertise

