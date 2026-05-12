# Firebase Schema

## Collections overview

```text
users/{userId}
users/{userId}/cases/{caseId}
users/{userId}/usage/{yyyyMMdd}
feedback/{feedbackId}
appConfig/{configDoc}
moderationLogs/{logId}
```

## users/{userId}

```json
{
  "uid": "abc123",
  "email": "user@example.com",
  "displayName": "Chris",
  "createdAt": "timestamp",
  "lastActiveAt": "timestamp",
  "authProvider": "apple|google|email|anonymous",
  "isAnonymous": false,
  "subscription": {
    "status": "free|trial|plus|expired",
    "revenueCatCustomerId": "string optional",
    "entitlement": "settle_plus optional",
    "currentPeriodEnd": "timestamp optional"
  },
  "settings": {
    "defaultTone": "balanced_referee",
    "allowPg13Humor": false,
    "saveHistoryByDefault": true,
    "analyticsOptOut": false
  },
  "counters": {
    "totalCasesCreated": 0,
    "totalShares": 0,
    "totalHelpfulVotes": 0
  }
}
```

## users/{userId}/cases/{caseId}

```json
{
  "caseId": "case_123",
  "userId": "abc123",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "promptVersion": "v1.0.0",
  "model": "model-name",
  "relationshipType": "partner|roommate|friend|family|coworker|other",
  "tone": "balanced_referee|playful_roast|courtroom_judge",
  "status": "completed|blocked|needs_soft_redirect|error",
  "input": {
    "scenarioSanitized": "string",
    "sideASanitized": "string optional",
    "sideBSanitized": "string optional",
    "inputCharCount": 0,
    "containsPotentialPII": false
  },
  "safety": {
    "riskLevel": "low|medium|high",
    "categories": ["none"],
    "blockedReason": "string optional",
    "safeForHumor": true,
    "safeForShare": true
  },
  "verdict": {
    "title": "The Cat Pee Laundry Case",
    "summaryVerdict": "You were not stupid, but the shirt deserved a solo wash first.",
    "whoWasMoreRight": "both",
    "confidence": "medium",
    "sideAGotRight": "You acted quickly before the smell set in.",
    "sideBGotRight": "She was right that cat urine should usually be treated separately.",
    "whatWasMissed": "The shared load should not be dried until the odor is gone.",
    "practicalFix": "Rewash the affected items with enzyme cleaner and air dry first.",
    "funnyFinalRuling": "The court sentences the shirt to one private enzyme spa day.",
    "textToSend": "You were right that I should have washed it separately first...",
    "safetyNote": null
  },
  "share": {
    "shareCount": 0,
    "lastSharedAt": "timestamp optional",
    "shareCardTitle": "Laundry Court Has Spoken"
  },
  "feedback": {
    "userRating": null,
    "wasHelpful": null,
    "wasFunny": null,
    "wasFair": null,
    "reported": false
  },
  "deletedAt": null
}
```

## users/{userId}/usage/{yyyyMMdd}

```json
{
  "dateKey": "20260506",
  "userId": "abc123",
  "freeVerdictsUsed": 0,
  "paidVerdictsUsed": 0,
  "rerollsUsed": 0,
  "shareCardsCreated": 0,
  "lastUpdatedAt": "timestamp"
}
```

## feedback/{feedbackId}

```json
{
  "feedbackId": "fb_123",
  "caseId": "case_123",
  "userId": "abc123",
  "createdAt": "timestamp",
  "rating": "thumbs_up|thumbs_down",
  "tags": ["funny", "fair", "too_harsh", "not_helpful"],
  "freeText": "optional user feedback",
  "tone": "balanced_referee",
  "promptVersion": "v1.0.0"
}
```

## moderationLogs/{logId}

Store only what is necessary for debugging safety issues. Do not store raw sensitive content unless required and disclosed.

```json
{
  "logId": "mod_123",
  "createdAt": "timestamp",
  "userId": "abc123 optional",
  "caseId": "case_123 optional",
  "riskLevel": "low|medium|high",
  "categories": ["abuse", "self_harm", "legal"],
  "action": "allowed|soft_redirect|blocked",
  "promptVersion": "v1.0.0"
}
```

## appConfig/global

```json
{
  "freeVerdictsPerDay": 3,
  "maxInputChars": 3000,
  "enablePg13Tone": false,
  "enablePublicFeed": false,
  "enableVoiceInput": false,
  "maintenanceMode": false,
  "minimumAppVersion": "1.0.0"
}
```

## Firestore security rules draft

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return signedIn() && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read: if isOwner(userId);
      allow create: if isOwner(userId);
      allow update: if isOwner(userId)
        && !('subscription' in request.resource.data.diff(resource.data).changedKeys());
      allow delete: if isOwner(userId);

      match /cases/{caseId} {
        allow read: if isOwner(userId);
        allow create: if false; // only Cloud Functions create cases
        allow update: if isOwner(userId)
          && request.resource.data.diff(resource.data).changedKeys().hasOnly([
            'feedback', 'share', 'updatedAt', 'deletedAt'
          ]);
        allow delete: if isOwner(userId);
      }

      match /usage/{dateKey} {
        allow read: if isOwner(userId);
        allow write: if false; // only backend
      }
    }

    match /feedback/{feedbackId} {
      allow create: if signedIn() && request.resource.data.userId == request.auth.uid;
      allow read, update, delete: if false;
    }

    match /appConfig/{docId} {
      allow read: if true;
      allow write: if false;
    }

    match /moderationLogs/{logId} {
      allow read, write: if false;
    }
  }
}
```

