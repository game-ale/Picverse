# Picverse — Firebase & Supabase Setup Guide

> **Complete step-by-step guide** to configure Firebase and Supabase from scratch so the app compiles and runs.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Firebase Project Setup](#2-firebase-project-setup)
3. [Firebase Authentication](#3-firebase-authentication)
4. [Cloud Firestore Database](#4-cloud-firestore-database)
5. [Firestore Security Rules](#5-firestore-security-rules)
6. [Firestore Indexes](#6-firestore-indexes)
7. [Supabase Project Setup](#7-supabase-project-setup)
8. [Supabase Storage Buckets](#8-supabase-storage-buckets)
9. [Supabase Storage Policies](#9-supabase-storage-policies)
10. [Connect Firebase to Flutter (FlutterFire CLI)](#10-connect-firebase-to-flutter-flutterfire-cli)
11. [Fill in the .env File](#11-fill-in-the-env-file)
12. [Google Sign-In Setup](#12-google-sign-in-setup)
13. [Android-Specific Setup](#13-android-specific-setup)
14. [iOS-Specific Setup](#14-ios-specific-setup)
15. [Final Verification Checklist](#15-final-verification-checklist)
16. [Troubleshooting](#16-troubleshooting)

---

## 1. Prerequisites

Install these before starting:

| Tool | Install Command / Link |
|------|----------------------|
| **Flutter SDK** | https://docs.flutter.dev/get-started/install |
| **Firebase CLI** | `npm install -g firebase-tools` |
| **FlutterFire CLI** | `dart pub global activate flutterfire_cli` |
| **Google account** | For Firebase Console |
| **GitHub account** *(optional)* | For Supabase login |

Verify installations:

```bash
flutter --version        # Should show ≥ 3.9.2
firebase --version       # Should show ≥ 13.x
flutterfire --version    # Should show ≥ 1.x
```

---

## 2. Firebase Project Setup

### Step 1 — Create the Project

1. Go to **[Firebase Console](https://console.firebase.google.com)**
2. Click **"Create a project"** (or "Add project")
3. Enter project name: **`picverse`** (or any name you like)
4. **Disable** Google Analytics (we don't use it yet) → click **Create Project**
5. Wait for the project to be provisioned → click **Continue**

### Step 2 — Upgrade to Blaze Plan (Required for Firestore)

1. In the Firebase Console sidebar → click ⚙️ **Project Settings** → **Usage and billing**
2. Click **Modify plan** → select **Blaze (pay as you go)**
3. Link a billing account (you will NOT be charged for normal development usage)

> **Why?** The free Spark plan limits Firestore reads/writes. Blaze is free up to generous quotas.

---

## 3. Firebase Authentication

### Step 1 — Enable Email/Password Provider

1. Firebase Console → sidebar → **Build** → **Authentication**
2. Click **Get started**
3. Go to **Sign-in method** tab
4. Click **Email/Password** → toggle **Enable** → **Save**

### Step 2 — Enable Google Sign-In Provider

1. Still on **Sign-in method** tab
2. Click **Google** → toggle **Enable**
3. Set a **Project support email** (pick your email)
4. Click **Save**

### Step 3 — Configure Authorized Domains (Optional)

Under **Authentication** → **Settings** → **Authorized domains**, `localhost` and your Firebase domains are already added. If you deploy a web version later, add your domain here.

---

## 4. Cloud Firestore Database

### Step 1 — Create the Database

1. Firebase Console → sidebar → **Build** → **Firestore Database**
2. Click **Create database**
3. Choose a location closest to your users (e.g., `us-central1`, `europe-west1`)
   > ⚠️ **This cannot be changed later!** Pick wisely.
4. Start in **Test mode** for now (we'll set proper rules in Step 5)
5. Click **Create**

### Step 2 — Understand the Collections

The app uses **7 collections** — they are auto-created when the app writes data, but here's the schema:

#### `users` (doc ID = Firebase Auth UID)
| Field | Type | Example |
|-------|------|---------|
| `username` | string | `"john_doe"` |
| `email` | string | `"john@example.com"` |
| `bio` | string | `"Hello world"` |
| `profileImage` | string | Supabase public URL |
| `followersCount` | number | `42` |
| `followingCount` | number | `18` |
| `postsCount` | number | `7` |
| `role` | string | `"user"` or `"admin"` |
| `status` | string | `"active"` or `"banned"` |
| `createdAt` | timestamp | server timestamp |

#### `posts` (doc ID = auto-generated)
| Field | Type | Example |
|-------|------|---------|
| `userId` | string | Firebase Auth UID |
| `username` | string | `"john_doe"` |
| `userProfileImage` | string | Supabase public URL |
| `imageUrl` | string | Supabase public URL |
| `caption` | string | `"Sunset vibes 🌅"` |
| `likesCount` | number | `12` |
| `commentsCount` | number | `3` |
| `createdAt` | timestamp | server timestamp |

#### `comments` (doc ID = auto-generated)
| Field | Type | Example |
|-------|------|---------|
| `postId` | string | post document ID |
| `userId` | string | commenter's UID |
| `username` | string | `"jane_doe"` |
| `text` | string | `"Amazing photo!"` |
| `createdAt` | timestamp | server timestamp |

#### `likes` (doc ID = `{userId}_{postId}`)
| Field | Type | Example |
|-------|------|---------|
| `postId` | string | post document ID |
| `userId` | string | liker's UID |
| `createdAt` | timestamp | server timestamp |

#### `follows` (doc ID = `{followerId}_{followingId}`)
| Field | Type | Example |
|-------|------|---------|
| `followerId` | string | who is following |
| `followingId` | string | who is being followed |
| `createdAt` | timestamp | server timestamp |

#### `notifications` (doc ID = auto-generated)
| Field | Type | Example |
|-------|------|---------|
| `userId` | string | notification recipient |
| `type` | string | `"like"`, `"comment"`, or `"follow"` |
| `actorId` | string | who triggered it |
| `actorUsername` | string | `"john_doe"` |
| `postId` | string (nullable) | related post ID |
| `isRead` | boolean | `false` |
| `createdAt` | timestamp | server timestamp |

#### `reports` (doc ID = auto-generated)
| Field | Type | Example |
|-------|------|---------|
| `postId` | string | reported post ID |
| `reportedBy` | string | reporter's UID |
| `reason` | string | `"spam"`, `"harassment"`, etc. |
| `status` | string | `"pending"`, `"resolved"`, `"dismissed"` |
| `createdAt` | timestamp | server timestamp |

> 💡 You do **NOT** need to manually create these collections. Firestore creates them automatically when the app writes the first document.

---

## 5. Firestore Security Rules

1. Firebase Console → **Firestore Database** → **Rules** tab
2. Replace the default rules with:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // Helper: is the user logged in?
    function isAuth() {
      return request.auth != null;
    }

    // Helper: is this the document owner?
    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    // Helper: is this user an admin?
    function isAdmin() {
      return isAuth() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // ─── USERS ───
    match /users/{userId} {
      allow read: if isAuth();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId) || isAdmin();
      allow delete: if false; // Never delete user docs
    }

    // ─── POSTS ───
    match /posts/{postId} {
      allow read: if isAuth();
      allow create: if isAuth() && request.resource.data.userId == request.auth.uid;
      allow update: if isAuth(); // For like count increments
      allow delete: if isAuth() &&
        (resource.data.userId == request.auth.uid || isAdmin());
    }

    // ─── COMMENTS ───
    match /comments/{commentId} {
      allow read: if isAuth();
      allow create: if isAuth() && request.resource.data.userId == request.auth.uid;
      allow delete: if isAuth() &&
        (resource.data.userId == request.auth.uid || isAdmin());
    }

    // ─── LIKES ───
    match /likes/{likeId} {
      allow read: if isAuth();
      allow create: if isAuth();
      allow delete: if isAuth();
    }

    // ─── FOLLOWS ───
    match /follows/{followId} {
      allow read: if isAuth();
      allow create: if isAuth();
      allow delete: if isAuth();
    }

    // ─── NOTIFICATIONS ───
    match /notifications/{notifId} {
      allow read: if isAuth() && resource.data.userId == request.auth.uid;
      allow create: if isAuth();
      allow update: if isAuth() && resource.data.userId == request.auth.uid;
      allow delete: if false;
    }

    // ─── REPORTS ───
    match /reports/{reportId} {
      allow read: if isAdmin();
      allow create: if isAuth();
      allow update: if isAdmin();
      allow delete: if false;
    }
  }
}
```

3. Click **Publish**

---

## 6. Firestore Indexes

The app makes compound queries that require composite indexes. Create them:

1. Firebase Console → **Firestore Database** → **Indexes** tab
2. Click **Create index** for each row below:

| Collection | Field 1 | Field 2 | Query Scope |
|------------|---------|---------|-------------|
| `posts` | `userId` (Ascending) | `createdAt` (Descending) | Collection |
| `comments` | `postId` (Ascending) | `createdAt` (Descending) | Collection |
| `notifications` | `userId` (Ascending) | `createdAt` (Descending) | Collection |
| `notifications` | `userId` (Ascending) | `isRead` (Ascending) | Collection |
| `reports` | `status` (Ascending) | `createdAt` (Descending) | Collection |

> 💡 **Shortcut:** If you skip this, running the app will print error messages in the debug console with direct links to auto-create each missing index. Just click those links.

---

## 7. Supabase Project Setup

### Step 1 — Create an Account & Project

1. Go to **[Supabase Dashboard](https://supabase.com/dashboard)**
2. Sign in (GitHub, email, or SSO)
3. Click **New project**
4. Fill in:
   - **Name:** `picverse`
   - **Database password:** Generate a strong one (save it somewhere)
   - **Region:** Same region as your Firebase (e.g., US East / EU West)
5. Click **Create new project** → wait ~2 minutes

### Step 2 — Get Your API Keys

1. Once created, go to **Project Settings** (gear icon) → **API**
2. Copy these two values:

| Value | Where to Find | Paste Into |
|-------|--------------|------------|
| **Project URL** | Under "Project URL" | `.env` → `SUPABASE_URL` |
| **anon / public key** | Under "Project API keys" → `anon` `public` | `.env` → `SUPABASE_ANON_KEY` |

> ⚠️ **Never** use the `service_role` key in a client app. Only use `anon`.

---

## 8. Supabase Storage Buckets

### Step 1 — Create `post-images` Bucket

1. Supabase Dashboard → sidebar → **Storage**
2. Click **New bucket**
3. Name: **`post-images`**
4. Toggle **Public bucket** → **ON**
5. Allowed MIME types: `image/jpeg, image/png, image/webp, image/gif`
6. Max file size: **5 MB** (or your preference)
7. Click **Create bucket**

### Step 2 — Create `profile-images` Bucket

1. Click **New bucket** again
2. Name: **`profile-images`**
3. Toggle **Public bucket** → **ON**
4. Allowed MIME types: `image/jpeg, image/png, image/webp`
5. Max file size: **2 MB**
6. Click **Create bucket**

---

## 9. Supabase Storage Policies

Both buckets need policies so users can upload/delete their own files.

### Option A — Via Dashboard UI

1. Go to **Storage** → click **`post-images`** → **Policies** tab
2. Click **New policy** → **For full customization**
3. Create these policies:

**Policy 1 — Anyone can READ (public bucket):**
- Name: `Public read access`
- Allowed operation: `SELECT`
- Target roles: `anon`, `authenticated`
- Policy definition: `true`

**Policy 2 — Authenticated users can UPLOAD:**
- Name: `Auth users can upload`
- Allowed operation: `INSERT`
- Target roles: `authenticated`
- Policy definition: `true`

**Policy 3 — Users can DELETE own files:**
- Name: `Users can delete own files`
- Allowed operation: `DELETE`
- Target roles: `authenticated`
- Policy definition: `true`

4. Repeat the same 3 policies for the **`profile-images`** bucket.

### Option B — Via SQL Editor (Faster)

Go to **SQL Editor** and run:

```sql
-- post-images policies
CREATE POLICY "Public read post-images"
  ON storage.objects FOR SELECT
  USING ( bucket_id = 'post-images' );

CREATE POLICY "Auth upload post-images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'post-images'
    AND auth.role() = 'authenticated'
  );

CREATE POLICY "Auth delete post-images"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'post-images'
    AND auth.role() = 'authenticated'
  );

-- profile-images policies
CREATE POLICY "Public read profile-images"
  ON storage.objects FOR SELECT
  USING ( bucket_id = 'profile-images' );

CREATE POLICY "Auth upload profile-images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'profile-images'
    AND auth.role() = 'authenticated'
  );

CREATE POLICY "Auth update profile-images"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'profile-images'
    AND auth.role() = 'authenticated'
  );

CREATE POLICY "Auth delete profile-images"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'profile-images'
    AND auth.role() = 'authenticated'
  );
```

> The `profile-images` bucket also needs an **UPDATE** policy because the app uses `upsert: true` when uploading avatars (overwrites the existing file).

---

## 10. Connect Firebase to Flutter (FlutterFire CLI)

This is the **most critical step** — it generates the config files the app needs.

### Step 1 — Login to Firebase

```bash
firebase login
```

A browser window opens → sign in with your Google account.

### Step 2 — Run FlutterFire Configure

From the project root (`c:\mobile app\Picverse`):

```bash
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

Replace `YOUR_FIREBASE_PROJECT_ID` with the actual ID from Firebase Console → ⚙️ Project Settings → General → **Project ID** (e.g., `picverse-12345`).

The CLI will ask:
1. **Which platforms?** → Select **Android** and **iOS** (use Space to select, Enter to confirm)
2. **Android package name?** → Enter: `com.example.picverse` (or check `android/app/build.gradle` for the real one)
3. **iOS bundle ID?** → Enter: `com.example.picverse`

This generates:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

### Step 3 — Initialize Firebase from Native Config

This project uses the platform config files directly:

```dart
await Firebase.initializeApp();
```

Keep these files out of git unless you explicitly want public client config tracked:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

If you rotate Firebase keys, re-download those files from Firebase Console and replace the local copies.

---

## 11. Fill in the .env File

Open `.env` in the project root and fill in the real values:

```dotenv
# Firebase Configuration
FIREBASE_API_KEY=AIzaSy...your_real_key
FIREBASE_APP_ID=1:123456789:android:abc123
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_PROJECT_ID=picverse-12345

# Supabase Configuration
SUPABASE_URL=https://abcdefghijk.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs...your_real_anon_key
```

**Where to find each value:**

| Key | Where |
|-----|-------|
| `FIREBASE_API_KEY` | Firebase Console → ⚙️ Project Settings → General → Web API Key |
| `FIREBASE_APP_ID` | Firebase Console → ⚙️ Project Settings → General → Your apps → App ID |
| `FIREBASE_MESSAGING_SENDER_ID` | Firebase Console → ⚙️ Project Settings → General → Cloud Messaging → Sender ID |
| `FIREBASE_PROJECT_ID` | Firebase Console → ⚙️ Project Settings → General → Project ID |
| `SUPABASE_URL` | Supabase Dashboard → Project Settings → API → Project URL |
| `SUPABASE_ANON_KEY` | Supabase Dashboard → Project Settings → API → `anon` `public` key |

> ⚠️ **NEVER commit `.env` to Git.** Ensure `.env` is in your `.gitignore`.

---

## 12. Google Sign-In Setup

### Android

1. Open the **Firebase Console** → ⚙️ **Project Settings** → **General**
2. Scroll to **Your apps** → select the Android app
3. Copy the **SHA-1 certificate fingerprint** section — if empty, add one:

```bash
# Run from your project root:
cd android
./gradlew signingReport
```

Look for `SHA1:` under `Variant: debug` → copy that hash.

4. Paste the SHA-1 into Firebase Console → **Add fingerprint** → **Save**
5. **Re-download** `google-services.json` and place it in `android/app/`

> Without the SHA-1, Google Sign-In will fail with error `PlatformException(sign_in_failed, ...)`.

### iOS

1. Open `ios/Runner/Info.plist`
2. FlutterFire CLI adds the `REVERSED_CLIENT_ID` automatically. If not, find it in `GoogleService-Info.plist` and add to `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

---

## 13. Android-Specific Setup

### `android/app/build.gradle`

Ensure these are set:

```groovy
android {
    compileSdk = 35           // or latest
    
    defaultConfig {
        minSdk = 23          // Firebase Auth requires 23+
        targetSdk = 35
        multiDexEnabled true // Required for Firebase
    }
}
```

### `android/build.gradle`

Ensure the Google services plugin is applied. FlutterFire CLI handles this, but verify:

```groovy
// In android/build.gradle or android/app/build.gradle:
plugins {
    id 'com.google.gms.google-services' // Should already exist
}
```

### Internet Permission

Check `android/app/src/main/AndroidManifest.xml` has:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---

## 14. iOS-Specific Setup

### Minimum iOS Version

Open `ios/Podfile` and ensure:

```ruby
platform :ios, '15.0'   # Firebase requires >= 13.0, recommended 15.0+
```

### Set the same in Xcode (if needed)

If you have Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select **Runner** target → **General** → **Deployment Info** → set to **15.0**

### Install Pods

```bash
cd ios
pod install
cd ..
```

---

## 15. Final Verification Checklist

Run through this checklist **before** launching the app:

### Firebase Console
- [ ] Project created
- [ ] **Authentication** → Email/Password enabled
- [ ] **Authentication** → Google Sign-In enabled
- [ ] **Firestore Database** → Created
- [ ] **Firestore** → Security rules published (from Section 5)
- [ ] **Firestore** → Composite indexes created (from Section 6)
- [ ] Android app registered (SHA-1 added)
- [ ] iOS app registered (if targeting iOS)

### Supabase Dashboard
- [ ] Project created
- [ ] **Storage** → `post-images` bucket created (public)
- [ ] **Storage** → `profile-images` bucket created (public)
- [ ] **Storage** → Policies created for both buckets (from Section 9)

### Project Files
- [ ] `.env` filled with real values
- [ ] `.env` is in `.gitignore`
- [ ] `android/app/google-services.json` exists (from FlutterFire CLI)
- [ ] `ios/Runner/GoogleService-Info.plist` exists (if targeting iOS)
- [ ] `main.dart` calls `Firebase.initializeApp()`

### Build Test

```bash
flutter clean
flutter pub get
flutter run
```

The app should:
1. ✅ Launch without crashing
2. ✅ Show login/register screen
3. ✅ Allow email/password registration
4. ✅ Allow Google Sign-In
5. ✅ Create user document in Firestore `users` collection
6. ✅ Allow posting images (uploads to Supabase `post-images`)
7. ✅ Show feed with posts

---

## 16. Troubleshooting

### `FirebaseException: No Firebase App '[DEFAULT]'`
→ `google-services.json` is missing or in the wrong directory. Run `flutterfire configure` again.

### `PlatformException(sign_in_failed, ...)`
→ SHA-1 fingerprint not added to Firebase Console. See Section 12.

### `StorageException: Bucket not found`
→ The bucket name in code doesn't match Supabase. Bucket names must be exactly `post-images` and `profile-images`.

### `StorageException: new row violates row-level security`
→ Storage policies are missing. See Section 9.

### `PERMISSION_DENIED: Missing or insufficient permissions`
→ Firestore rules are still in locked mode, or you haven't published the rules from Section 5.

### `Failed to load Firestore indexes`
→ The app queries need composite indexes. Click the link in the error log (it auto-creates the index), or manually create them per Section 6.

### `XMLHttpRequest error` (Web)
→ CORS issue. Supabase Storage handles CORS automatically for public buckets. If using Firebase Storage instead, configure CORS on the GCS bucket.

### `MissingPluginException`
→ Run `flutter clean && flutter pub get` then rebuild. On iOS also run `cd ios && pod install`.

### Dark mode not persisting
→ Make sure `SharedPreferences` is initialized before `ThemeCubit`. The current code handles this.

---

## Quick Reference: What Goes Where

```
Picverse/
├── .env                          ← YOUR Supabase URL + keys, Firebase IDs
├── .gitignore                    ← Must contain: .env and Firebase config files
├── lib/
│   └── main.dart                 ← Firebase.initializeApp() + Supabase.initialize()
├── android/
│   └── app/
│       └── google-services.json  ← Generated by: flutterfire configure
└── ios/
    └── Runner/
        └── GoogleService-Info.plist  ← Generated by: flutterfire configure
```
---

**You're all set!** 🎉 Follow the sections in order, and the app will be fully connected.
