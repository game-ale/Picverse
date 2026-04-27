# Picverse Project Documentation

Picverse is a Flutter social media application inspired by Instagram. It supports authentication, social feeds, posts, comments, likes, follows, notifications, chat, admin moderation, localization, and offline-aware client behavior.

This document describes the current codebase as implemented in this repository.

## Table of contents

1. Overview
2. Tech stack
3. Core features
4. App architecture
5. Project structure
6. Navigation and routes
7. Data model and Firestore collections
8. Firebase setup
9. Environment and local setup
10. Localization
11. Admin experience
12. Chat experience
13. Filtering and search
14. Notifications
15. Testing
16. Build and run
17. Troubleshooting

---

## 1. Overview

Picverse is a mobile-first social app built with Flutter and Firebase. It focuses on:

- User authentication
- Social posting and feed browsing
- Commenting, liking, following, and notifications
- Direct messages and group chats
- Admin moderation tools
- Offline-friendly behavior where practical
- Multi-language UI support

The app follows a clean, layered structure with BLoC for state management.

---

## 2. Tech stack

### Frontend

- Flutter
- Dart
- `flutter_bloc`
- `go_router`
- `equatable`
- `cached_network_image`
- `google_fonts`
- `flutter_localizations`

### Backend and platform services

- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging
- Firebase Storage
- Firebase Cloud Functions
- Firebase Analytics

### Local storage and utilities

- Hive
- `connectivity_plus`
- `intl`
- `uuid`
- `flutter_dotenv`

### Testing

- `flutter_test`
- `bloc_test`
- `mocktail`

---

## 3. Core features

### Authentication

- Email/password login
- Email/password registration
- Password reset
- Google sign-in
- Auth state handling with redirects

### Social feed

- Personalized feed from followed users plus self posts
- Pull-to-refresh
- Infinite scroll / load more
- Offline fallback with local cache

### Posts

- Create post with image and caption
- Like and unlike
- Comment on posts
- Report posts
- Open post owners’ profiles

### Social graph

- Follow and unfollow users
- View followers and following lists
- Profile pages with post grids

### Notifications

- In-app notification feed
- Real-time notification stream updates
- Mark single notification as read
- Mark all notifications as read
- Push notification token registration

### Chat

- Direct 1:1 messages
- Group chats
- Chat list
- Chat room detail
- Group chat creation
- Read tracking in room metadata

### Admin

- Admin-only app shell and dashboard
- View overview statistics
- List and moderate users
- List and moderate posts
- Review and resolve reports

### Localization

- English
- Afaan Oromo
- Amharic
- Persistent language preference

### Filtering

- Search result filtering
- Feed post filtering
- Followers/following filtering

---

## 4. App architecture

Picverse uses a layered clean-architecture style:

### Presentation layer

- Screens/pages
- Widgets
- BLoC classes

### Domain layer

- Entities
- Repository interfaces

### Data layer

- Repository implementations
- Firestore-backed models

### Services and infrastructure

- Firebase and Firestore service wrapper
- Auth service
- Storage service
- Push notification service
- Local cache service
- Connectivity service

This structure keeps UI, business rules, and data access separated.

---

## 5. Project structure

High-level directories:

- `lib/core`
  - shared constants, services, theme, localization, widgets
- `lib/features/auth`
- `lib/features/feed`
- `lib/features/post`
- `lib/features/profile`
- `lib/features/search`
- `lib/features/notification`
- `lib/features/chat`
- `lib/features/admin`
- `lib/routes`
- `test`

Important files:

- `lib/main.dart` — app bootstrap
- `lib/injection_container.dart` — dependency injection
- `lib/routes/app_router.dart` — navigation and guards
- `lib/core/services/firestore_service.dart` — Firestore abstraction
- `lib/core/local/app_localizations.dart` — localization strings
- `lib/core/local/language_cubit.dart` — persisted language selection
- `lib/core/theme/theme_cubit.dart` — persisted theme selection

---

## 6. Navigation and routes

Navigation is handled by `go_router`.

### Auth routes

- `/splash`
- `/login`
- `/register`
- `/reset-password`

### Social and detail routes

- `/`
- `/search`
- `/create-post`
- `/notifications`
- `/profile`
- `/profile/:userId`
- `/edit-profile`
- `/followers/:userId`
- `/comments/:postId`

### Chat routes

- `/chats`
- `/chats/create-group`
- `/chats/open/:userId`
- `/chats/:roomId`

### Admin route

- `/admin`

### Route behavior

- Unauthenticated users are redirected to `/login`
- Authenticated users are routed to the main app
- Admin users are routed to the admin dashboard shell
- Non-admin users cannot stay in the admin shell

---

## 7. Data model and Firestore collections

Picverse uses Firestore as the main source of truth.

### `users`

Document ID: Firebase Auth UID

Fields:

- `username`
- `email`
- `bio`
- `profileImage`
- `followersCount`
- `followingCount`
- `postsCount`
- `role`
- `status`
- `fcmTokens`
- `createdAt`

### `posts`

Document ID: auto-generated

Fields:

- `userId`
- `username`
- `userProfileImage`
- `imageUrl`
- `caption`
- `likesCount`
- `commentsCount`
- `createdAt`

### `comments`

Fields:

- `postId`
- `userId`
- `username`
- `text`
- `createdAt`

### `likes`

Document ID: `${userId}_${postId}`

Fields:

- `postId`
- `userId`
- `createdAt`

### `follows`

Document ID: `${followerId}_${followingId}`

Fields:

- `followerId`
- `followingId`
- `createdAt`

### `notifications`

Fields:

- `userId`
- `type`
- `actorId`
- `actorUsername`
- `postId`
- `isRead`
- `createdAt`

### `reports`

Fields:

- `postId`
- `reportedBy`
- `reason`
- `status`
- `createdAt`

### `chatRooms`

Fields:

- `participantIds`
- `participantUsernames`
- `participantProfileImages`
- `isGroup`
- `groupName`
- `createdBy`
- `lastMessage`
- `lastMessageAt`
- `unreadCounts`
- `createdAt`
- `updatedAt`

### `chatMessages`

Fields:

- `roomId`
- `senderId`
- `senderUsername`
- `text`
- `createdAt`

---

## 8. Firebase setup

The repository includes:

- `firebase.json`
- `firestore.rules`
- `firestore.indexes.json`
- `functions/`

### Authentication

Firebase Auth is used for:

- Email/password login and registration
- Google sign-in

### Firestore

Firestore is used for:

- Users
- Posts
- Comments
- Likes
- Follows
- Notifications
- Reports
- Chat rooms
- Chat messages

### Cloud Messaging

Firebase Cloud Messaging is used for:

- Push notification token registration
- Device token refresh handling
- Notification delivery from backend triggers

### Storage

Firebase Storage is used for:

- Post image uploads
- Profile image uploads

### Cloud Functions

The repo includes a function that sends push notifications when notification documents are created.

---

## 9. Environment and local setup

### Requirements

- Flutter SDK compatible with Dart `^3.9.2`
- Firebase project
- Android Studio / Xcode as needed

### Environment file

The app loads `.env` at startup. The file is listed in Flutter assets.

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

### Recommended validation

```bash
flutter analyze
flutter test
```

---

## 10. Localization

The app supports:

- English
- Afaan Oromo
- Amharic

### How localization works

- `AppLocalizations` holds localized strings
- `LanguageCubit` stores the selected locale in Hive
- `MaterialApp.router` receives the active locale
- The user can change language from the profile settings sheet

### Localized areas

- Login
- Registration
- Password reset
- Main navigation labels
- Search
- Notifications
- Chat
- Profile settings

---

## 11. Admin experience

Admin users get a separate shell and a dedicated dashboard.

### Admin dashboard sections

- Overview
- Users
- Posts
- Reports

### Admin capabilities

- View totals and recent reports
- Ban and unban users
- Delete posts
- Resolve or dismiss reports

### Access control

Admin access is enforced at the router level and in Firestore rules.

---

## 12. Chat experience

### Direct messages

- Start from search or a profile page
- A direct chat room is created if one does not already exist
- Messages stream in real time

### Group chats

- Create a group room from the chat list
- Add multiple participants
- Set a group name

### Chat room behavior

- Rooms track unread counts
- Rooms store last message and update time
- Messages are streamed and sorted chronologically

### Entry points

- Chat icon on the home screen
- Chat action in search results
- Chat action on user profiles

---

## 13. Filtering and search

### Search results

Search results can be filtered by:

- All
- Has bio
- Has photo

### Feed

Feed posts can be filtered by:

- All
- With caption
- With image

### Followers/following

Connection lists can be filtered by:

- All people
- With bio
- With profile photo

These filters are client-side and lightweight.

---

## 14. Notifications

### In-app notifications

The notifications screen loads initial data and then listens to Firestore updates.

### Push notifications

Pushes are supported through:

- FCM permission request
- Token registration on the user document
- Token refresh handling
- Cloud Function push delivery

### Notification types

- Like
- Comment
- Follow

---

## 15. Testing

The repository already includes automated tests for:

- Auth
- Feed
- Admin
- Profile
- Search
- Notifications
- Integration flows

### Run tests

```bash
flutter test
```

### Analyze code

```bash
flutter analyze
```

Both commands currently pass.

---

## 16. Build and run

### Android

```bash
flutter run -d android
```

### iOS

```bash
flutter run -d ios
```

### Release build examples

```bash
flutter build apk
flutter build ios
```

---

## 17. Troubleshooting

### App won’t start

- Make sure `flutter pub get` completed
- Confirm Firebase config files are present
- Verify `.env` exists if required by your runtime configuration

### Firestore permission errors

- Check `firestore.rules`
- Make sure the signed-in user’s `role` and ownership match the requested action

### Push notifications do not arrive

- Confirm the device token is stored on the user document
- Confirm the Cloud Function is deployed
- Confirm APNs / Android Firebase config is valid

### Localization does not change

- Confirm the profile settings sheet language selection is being used
- Check that `LanguageCubit` is initialized before `runApp`

---

## Notes

- `README.md` is still the default Flutter starter readme.
- `SETUP_GUIDE.md` still contains older Supabase-era steps and should be updated or replaced if you want the docs fully aligned with the current Firebase-only implementation.

