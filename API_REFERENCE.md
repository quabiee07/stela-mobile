# Stela REST API Reference

This document outlines the API endpoints, their purpose, request payloads, response payloads, and the authentication mechanism for the Stela mobile app backend.

---

## 1. Authentication Flow

To secure the backend, we use **dynamic user-specific Firebase ID Tokens** instead of a single static "universal key".

### Set Up Authentication:
1. Integrate the Firebase Auth SDK into the Kotlin application using the project's `google-services.json` configuration file (download this from the Firebase Console). This file contains the public parameters (like the project's `apiKey`) required to initialize the client SDK.
2. Sign the user in on the mobile device (e.g., via Google Sign-In or Email/Password).
3. Retrieve the user's **ID Token** dynamically in the application code:
   ```kotlin
   Firebase.auth.currentUser?.getIdToken(true)?.addOnSuccessListener { result ->
       val idToken = result.token
       // Pass this token in the header of your API requests
   }
   ```
4. Include this token in the headers of every API request (except `/health`):
   ```http
   Authorization: Bearer <ID_TOKEN>
   ```
5. The backend will automatically validate the token, extract your secure user UID, and execute the requested endpoint.

---

## 2. API Endpoints

### Base URL
- **Production (Hosting clean URL)**: `https://stela-mobile.web.app/api` (or custom domain if configured, e.g., `https://api.yourdomain.com/api`)
- **Production (Direct Function URL)**: `https://<region>-stela-mobile.cloudfunctions.net/api`
- **Emulator (Local)**: `http://10.0.2.2:5001/stela-mobile/us-central1/api/` *(Note: 10.0.2.2 routes to host localhost from Android Emulator)*

---

### Health Check

#### `GET /health`
- **Purpose**: Verifies if the backend API service is up and running.
- **Authentication**: None
- **Response (200 OK)**:
  ```json
  {
    "status": "ok",
    "service": "Stela Backend",
    "version": "2.0.0"
  }
  ```

---

### User Authentication & Settings (`/auth`)

#### `POST /auth/onboarding`
- **Purpose**: Saves user profile setup details during onboarding. Must be called after the user first signs up.
- **Authentication**: Firebase ID Token Required
- **Request Body (`application/json`)**:
  ```json
  {
    "name": "Jane Doe",
    "age": 8,
    "storyPreferences": ["fantasy", "sci-fi"]
  }
  ```
  - `name`: Non-empty string
  - `age`: Number (must be between 5 and 120)
  - `storyPreferences`: Array of strings (at least one choice)
- **Response (200 OK)**:
  ```json
  {
    "success": true
  }
  ```

#### `POST /auth/fcm-token`
- **Purpose**: Registers the device FCM push token. Also saves the user's timezone if provided.
- **Authentication**: Firebase ID Token Required
- **Request Body (`application/json`)**:
  ```json
  {
    "token": "fcm_token_string_here",
    "timezone": "America/New_York"
  }
  ```
  - `token`: Non-empty string (the device FCM token)
  - `timezone`: Optional string (IANA timezone ID, e.g., "Europe/London"). Used to align daily reminders and streak resets.
- **Response (200 OK)**:
  ```json
  {
    "success": true
  }
  ```

#### `PUT /auth/notification-preferences`
- **Purpose**: Modifies the user's daily reading reminder push notification options.
- **Authentication**: Firebase ID Token Required
- **Request Body (`application/json`)**:
  ```json
  {
    "dailyReminderEnabled": true,
    "reminderHour": 20
  }
  ```
  - `dailyReminderEnabled`: Boolean
  - `reminderHour`: Integer (between `0` and `23` representing hour of day)
- **Response (200 OK)**:
  ```json
  {
    "success": true
  }
  ```

---

### Reading Sessions (`/sessions`)

#### `POST /sessions/log`
- **Purpose**: Logs a completed chapter reading or listening session. Triggers streak updates, pre-calculates aggregate stats, and awards newly unlocked badges.
- **Anti-Cheat**: Limits logging to a maximum of 30 session requests per hour.
- **Idempotency**: Clients must generate a unique UUID `sessionId` locally. If a request fails due to network issues, retrying with the same `sessionId` is safe and will not log duplicate records or award double rewards.
- **Authentication**: Firebase ID Token Required
- **Request Body (`application/json`)**:
  ```json
  {
    "sessionId": "a8b9c10d-1234-5678-abcd-ef0123456789",
    "bookId": "book_101",
    "bookTitle": "The Lost Dragon",
    "genre": "fantasy",
    "chapterId": "chapter_3",
    "isAudioSession": false,
    "isBookComplete": false,
    "speedMultiplier": 1.0
  }
  ```
  - `sessionId`: String (UUID v4)
  - `bookId`: String
  - `bookTitle`: String
  - `genre`: Must be one of: `"fantasy"`, `"sci-fi"`, `"romance"`, `"thriller"`, `"mystery"`, `"ocean"`, `"history"`, `"biography"`, `"other"`
  - `chapterId`: String
  - `isAudioSession`: Boolean (true if listening to audiobook)
  - `isBookComplete`: Boolean (true if this session completes the entire book)
  - `speedMultiplier`: Must be one of: `1.0`, `1.25`, `1.5`, `2.0`
- **Response (200 OK)**:
  ```json
  {
    "success": true,
    "currentStreak": 3,
    "streakStatus": "active",
    "newBadges": ["book_worm"],
    "xpEarned": 15,
    "totalXp": 140,
    "level": 2,
    "levelProgress": 0.4
  }
  ```
  - `xpEarned`: XP awarded for this session (chapter ≈ 15, book complete ≈ 40).
  - `totalXp`: User's lifetime XP after this session.
  - `level`: Current level (100 XP per level on the client fallback curve).
  - `levelProgress`: 0–1 progress within the current level.
  *If the `sessionId` was already processed, the response indicates success but avoids processing again:*
  ```json
  {
    "success": true,
    "alreadyLogged": true
  }
  ```

---

### Streak Engine (`/streak`)

#### `GET /streak`
- **Purpose**: Fetches the user's current reading streak information. Day boundaries should use the user's timezone (same as reminders).
- **Authentication**: Firebase ID Token Required
- **Response (200 OK)**:
  ```json
  {
    "currentStreak": 5,
    "longestStreak": 14,
    "lastReadDate": "2026-05-20",
    "streakStatus": "active",
    "freezeAvailable": true,
    "freezeUsedThisMonth": false,
    "freezeActivatedDate": null,
    "weeklySessionCounts": [0, 1, 1, 0, 1, 0, 0],
    "lastUpdatedAt": {
      "_seconds": 1779318300,
      "_nanoseconds": 0
    }
  }
  ```
  - `streakStatus`: Can be `"active"`, `"frozen"`, or `"broken"`
  - `freezeAvailable`: If `true`, the user has a freeze powerup available.
  - `freezeUsedThisMonth`: Tracks if the freeze has already been used in the calendar month.
  - `weeklySessionCounts`: Optional Mon–Sun session counts for the current week (preferred over client reconstruction).

#### `POST /streak/freeze`
- **Purpose**: Activates a streak freeze to lock the user's current streak for the day. (Use when they cannot read).
- **Authentication**: Firebase ID Token Required
- **Response (200 OK)**:
  ```json
  {
    "success": true,
    "currentStreak": 5
  }
  ```
  - Returns `400 Bad Request` if no freeze is available or it has already been used this month.

---

### Badges (`/badges`)

#### `GET /badges`
- **Purpose**: Returns all achievements and badges unlocked by the user.
- **Authentication**: Firebase ID Token Required
- **Response (200 OK)**:
  ```json
  [
    {
      "badgeId": "book_worm",
      "unlockedAt": {
        "_seconds": 1779318300,
        "_nanoseconds": 0
      },
      "seen": false
    },
    {
      "badgeId": "dragon_tamer",
      "unlockedAt": {
        "_seconds": 1779318500,
        "_nanoseconds": 0
      },
      "seen": true
    }
  ]
  ```

#### `POST /badges/{badgeId}/seen`
- **Purpose**: Marks a newly unlocked badge as seen after the client celebration overlay.
- **Authentication**: Firebase ID Token Required
- **Response (200 OK)**:
  ```json
  {
    "success": true
  }
  ```

---

### XP Module (`/xp`)

#### `POST /xp/share`
- **Purpose**: Awards XP for sharing stats/badges on social media. Tracks total shares to trigger the `"social_butterfly"` badge.
- **Authentication**: Firebase ID Token Required
- **Response (200 OK)**:
  ```json
  {
    "success": true
  }
  ```
  - Awards 25 XP to the user.
  - Unlocks the `"social_butterfly"` badge when the user reaches 3 lifetime shares.


### Stories Collection (`/stories`)

#### `GET /stories`
- **Purpose**: Retrieves a list of all available stories (metadata only, no chapter contents) for the library / browse screen.
- **Authentication**: Firebase ID Token Required
- **Response (200 OK)**:
  ```json
  [
    {
      "storyId": "nGMIqNiEVizcJ1AlTY8i",
      "title": "The Library at the End of the World",
      "genre": "adventure",
      "description": "In a small town with a tiny library of 112 books, a boy who has read them all starts a letter campaign that changes the community forever.",
      "coverImageUrl": "",
      "readingTime": 32,
      "totalChapters": 10,
      "ageRange": {
        "min": 10,
        "max": 14
      }
    }
  ]
  ```

#### `GET /stories/:storyId`
- **Purpose**: Retrieves details for a specific story along with the metadata list of all its chapters (no paragraph contents) for the story details / chapter select screen.
- **Authentication**: Firebase ID Token Required
- **Response (200 OK)**:
  ```json
  {
    "storyId": "nGMIqNiEVizcJ1AlTY8i",
    "title": "The Library at the End of the World",
    "genre": "adventure",
    "description": "In a small town with a tiny library of 112 books, a boy who has read them all starts a letter campaign that changes the community forever.",
    "coverImageUrl": "",
    "readingTime": 32,
    "totalChapters": 10,
    "ageRange": {
      "min": 10,
      "max": 14
    },
    "chapters": [
      {
        "chapterId": "chapter_1",
        "chapterNumber": 1,
        "title": "The Last Outpost",
        "wordCount": 605,
        "imageUrl": ""
      }
    ]
  }
  ```

#### `GET /stories/:storyId/chapters/:chapterId`
- **Purpose**: Retrieves the full paragraph and sentence structure of a specific chapter for the reading screen.
- **Authentication**: Firebase ID Token Required
- **Response (200 OK)**:
  ```json
  {
    "storyId": "nGMIqNiEVizcJ1AlTY8i",
    "chapterId": "chapter_1",
    "chapterNumber": 1,
    "title": "The Last Outpost",
    "wordCount": 605,
    "imageUrl": "",
    "paragraphs": [
      {
        "paragraphIndex": 0,
        "sentences": [
          "There was a library in a small town in northern Nigeria, a town called Dutse that sat where the busy roads thinned out into quiet ones...",
          "That was the entire collection.",
          "Not one hundred and twelve thousand, or one hundred and twelve hundred."
        ]
      }
    ]
  }
  ```