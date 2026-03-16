# Picverse

An Instagram-inspired social media app built with Flutter, Firebase, and Supabase.

## Features

- Email/password and Google Sign-In authentication
- Image posts with captions
- Follow/unfollow users
- Like and comment on posts
- Real-time notifications
- Admin moderation panel
- Light/dark theme support
- Offline caching

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter |
| Authentication & Database | Firebase Auth + Cloud Firestore |
| Image Storage | Supabase Storage |
| State Management | flutter_bloc |
| Navigation | go_router |

## Setup

> **Full step-by-step instructions are in [SETUP_GUIDE.md](SETUP_GUIDE.md).**

### Quick Start (after completing the setup guide)

Once you have:
- Created your Firebase project and run `flutterfire configure`
- Created your Supabase project
- Filled in your `.env` file (see `.env.example`)

Run the app:

```bash
flutter clean
flutter pub get
flutter run
```

### Environment Variables

Copy `.env.example` to `.env` and fill in your credentials:

```bash
cp .env.example .env
```

Then edit `.env` with your Firebase and Supabase values. See [SETUP_GUIDE.md § 11](SETUP_GUIDE.md#11-fill-in-the-env-file) for where to find each value.

> ⚠️ Never commit `.env` to Git — it is already listed in `.gitignore`.
