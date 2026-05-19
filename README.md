# ClipZone

A TikTok-style short video sharing app built with Flutter and powered by CloudGallery backend.

## Features

- **Vertical Video Feed** — Swipe through short videos (TikTok-style)
- **Video Upload** — Record or select videos from gallery (max 60s, 100MB)
- **Discover** — Search videos by hashtags and categories
- **User Profiles** — View profiles, followers, following, and video counts
- **Social Features** — Like, comment, and share videos
- **Google OAuth** — Sign in with Google account
- **Cloud Storage** — Videos stored in Google Drive via CloudGallery API
- **Dark Mode** — Beautiful dark theme by default

## Tech Stack

- **Frontend:** Flutter (Android + iOS)
- **Backend:** CloudGallery (Node.js/Express)
- **Storage:** Google Drive API
- **Database:** Firebase Firestore
- **Auth:** Google OAuth 2.0

## Project Structure

```
lib/
  config/         # API config, theme
  models/         # Data models (User, Video, Comment)
  services/       # API services (auth, video, user)
  providers/      # State management (Provider)
  screens/        # App screens
    feed/          # Video feed (vertical scroll)
    discover/      # Search & explore
    upload/        # Video recording & upload
    profile/       # User profile
    comments/      # Comments bottom sheet
    settings/      # App settings
  widgets/        # Reusable widgets
```

## Getting Started

### Prerequisites

- Flutter SDK 3.12+
- Android Studio / Xcode
- CloudGallery backend running

### Setup

```bash
# Clone the repo
git clone https://github.com/ziaullahkhalid102/clipzone.git
cd clipzone

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Backend

This app uses [CloudGallery](https://github.com/ziaullahkhalid102/cloud-gallery) as its backend.

**API Endpoints:**
- `POST /api/clips/upload` — Upload video
- `GET /api/clips/feed` — Get video feed
- `GET /api/clips/trending` — Get trending videos
- `GET /api/clips/user/:userId` — Get user's videos
- `POST /api/clips/:id/like` — Toggle like
- `POST /api/clips/:id/view` — Record view
- `GET /api/clips/:id/comments` — Get comments
- `POST /api/clips/:id/comments` — Add comment
- `GET /api/profiles/:userId` — Get user profile
- `POST /api/profiles/:userId/follow` — Toggle follow
- `GET /api/search/videos?q=query` — Search videos
- `GET /api/search/users?q=query` — Search users

## Development Phases

- **Phase 1** (Current): Project setup, navigation, login, basic screens, backend endpoints
- **Phase 2**: Video player, upload flow, feed algorithm
- **Phase 3**: Social features (comments, likes, follow, notifications)
- **Phase 4**: Polish, performance, app store release

## License

Private - All rights reserved.
