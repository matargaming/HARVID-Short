# ShortiGo Web App Design

Date: 2026-06-12

## Goal

Build a public ShortiGo web app that brings the mobile app experience to desktop and mobile browsers. The default experience should follow the approved TikTok-like center-stage layout: left navigation, centered vertical video, right action rail, and top-right auth or wallet actions.

The web app should feel like ShortiGo, not a TikTok clone. It must reuse the existing ShortiGo Firebase backend, Firestore data model, public episode media URLs, brand assets, colors, and user-facing product logic from the mobile app.

## Approved Direction

Use a separate React, TypeScript, and Vite consumer app under `web/`.

This is preferred over Flutter Web because the current Flutter Firebase options do not configure web, and a browser-native React app will provide a stronger desktop video feed, routing, share-link, and Firebase Hosting experience. It is also preferred over merging into the existing `admin/` React app because public consumer product code should stay separate from studio/admin tooling.

## Product Shape

The first screen is the Shorts feed:

- Left sidebar with ShortiGo logo, search, For You, Explore, Following, Rewards, My List, Profile, and auth entry points.
- Centered vertical video player sized for short-drama playback, with click-to-pause, progress bar, loading state, error state, and locked-content state.
- Right action rail with follow, like, series info, save, and share actions.
- Top-right actions for login/profile, wallet/rewards, and app-oriented CTAs where appropriate.

The app uses ShortiGo's brand palette and existing assets:

- Background: `#0B0613`
- Surface: `#15101F`
- Elevated surface: `#1C1730`
- Divider: `#2A2440`
- Primary: `#8B5CF6`
- Accent: `#E879F9`
- VIP gold: `#FFD166`
- Text colors from `lib/core/theme/app_colors.dart`
- Logo and splash assets from `assets/branding/`

The layout should remain usable at desktop and narrow browser widths. On narrow screens, the sidebar collapses into compact navigation and the video remains the primary surface.

## Architecture

Create a new consumer web app rather than extending the admin app:

```text
web/
  src/
    app/
    components/
    features/
    firebase/
    repositories/
    shared/
```

Expected responsibilities:

- `firebase/`: Firebase initialization, Auth, Firestore, and config error handling.
- `repositories/`: Firestore mappers and query helpers for series, episodes, users, transactions, social actions, and rewards.
- `features/shorts/`: feed state, video playback, action rail, info panel, and lock handling.
- `features/discover/`: category tabs and series cards.
- `features/series/`: series detail and episode list.
- `features/auth/`: login, signup, Google sign-in, sign-out, and user document creation.
- `features/profile/`: wallet, VIP status, saved/followed/liked state, transactions, and account actions.
- `features/rewards/`: daily check-in and web-safe reward flow.
- `shared/`: formatting, loading, error, empty, toast, modal, and responsive shell components.

The web app should keep its own UI state in React hooks and context. It should not duplicate backend business rules in unrelated places; shared decisions such as access/lock state, compact count formatting, and share-link formatting should live in small reusable modules.

## Data Flow

The web app uses the same backend surface as mobile:

- Firebase Auth for login, signup, sign-out, and current user state.
- Firestore `series`, `episodes`, `users`, `transactions`, and `admin/featured`.
- Existing `episode.videoUrl` and `episode.thumbnailUrl` fields for public media playback.
- Firestore social updates matching `FirestoreSocialActionsGateway`:
  - Like/unlike episode and update `episodes/{id}.likeCount`.
  - Save/unsave series and update `series/{id}.saveCount`.
  - Follow/unfollow series and update `series/{id}.followerCount`.
  - Record shares and update `episodes/{id}.shareCount`.
- Rewards use the configured rewards API when available; otherwise, match the mobile Firestore fallback behavior.
- Access checks use the same user fields as mobile:
  - `isVip`
  - `vipExpiresAt`
  - `bonus`
  - `favoriteSeriesIds`
  - `unlockedEpisodeIds`
  - `likedEpisodeIds`
  - `followedSeriesIds`

Firestore reads for public catalog content remain public, consistent with the existing rules. Signed-in actions require Firebase Auth and should route unauthenticated users to login.

## Screens And Routes

Recommended routes:

- `/` redirects to `/shorts`.
- `/shorts` shows the TikTok-like feed using For You ordering.
- `/discover` shows category tabs for For You, New, Hot, Adventure, Scary, Anime, and VIP.
- `/series/:seriesId` shows series detail, description, saved/followed state, and ordered episodes.
- `/series/:seriesId/episodes/:episodeId` opens a direct player route for shared links.
- `/rewards` shows daily check-in and web reward actions.
- `/my-list` shows saved series.
- `/following` shows followed series.
- `/profile` shows wallet, VIP status, saved/followed/liked summaries, transactions, and sign-out.
- `/login` handles email/password and Google sign-in.
- `/subscribe` shows the VIP subscription CTA and explains locked content.

The web app should preserve the existing share-link shape from mobile:

```text
https://shortigo.app/series/:seriesId/episodes/:episodeId
```

## Core Functionality

The first build should include the mobile app's real user-facing surface:

- Shorts feed with keyboard, wheel, and touch navigation.
- Autoplay for the current video and preloading for nearby videos.
- Pause/play on click.
- Video progress bar.
- Loading, error, empty, and locked states.
- Discover categories using the same Firestore query behavior.
- Series detail with cover, description, episode list, lock labels, and watch actions.
- Email/password and Google auth where Firebase web config supports it.
- User document creation on first sign-in.
- Profile and wallet display.
- Rewards page with daily check-in and a web-safe reward action.
- My List and Following pages.
- Optimistic social actions with rollback or toast on failure.
- Subscribe CTA for VIP-locked content.

Native mobile IAP should not be ported directly to web in this first build. A real web payment provider or RevenueCat Web Billing integration should be a separate follow-up unless it is already configured before implementation starts.

## Error Handling

The app should handle:

- Missing Firebase web environment variables with a development-friendly config banner.
- Firestore read errors with retry controls.
- Video playback errors with retry and fallback thumbnail.
- Signed-out protected actions with a login prompt.
- Firestore permission failures with friendly toasts and UI rollback.
- Empty feeds and empty saved/following lists.
- Locked episodes with bonus unlock or VIP subscription CTA based on episode and user state.

## Testing And Verification

Testing should focus on behavior that can regress the product:

- Firestore mappers for `Series`, `Episode`, `AppUser`, and transactions.
- Category query helpers, including For You ordering from `admin/featured`.
- Access and locked-content decisions.
- Share-link generation.
- Social action optimistic updates and Firestore writes.
- Reward API versus Firestore fallback selection.
- Auth user document creation.

Verification before completion:

- TypeScript build passes.
- Unit tests pass.
- Production Vite build passes.
- Browser check at desktop width.
- Browser check at narrow/mobile width.
- Confirm the video surface renders nonblank when data is available.
- Confirm sidebar, action rail, and bottom/compact navigation do not overlap.
- Confirm Firebase config failure state is understandable in development.

## Deployment

The web app should be deployable as static assets. Firebase Hosting configuration can be updated if needed, but it must preserve existing legal/static pages and avoid breaking the admin app deployment path.

If Firebase Hosting needs multiple targets, define the consumer web app explicitly rather than replacing the current `hosting/public` pages by accident.

## Out Of Scope For First Build

- Real web payment integration for VIP subscription.
- A public upload or creator studio surface.
- Replacing the existing admin app.
- Changing Firestore schema unless an implementation blocker is found.
- Rewriting the Flutter mobile app.
- New backend services beyond small config wiring for existing rewards API behavior.

## Open Implementation Notes

- Confirm Firebase web app config values before implementation. The existing admin app expects `VITE_FIREBASE_*` environment variables, and the consumer web app can follow that pattern.
- Confirm whether the deployed domain should be `shortigo.app` or a Firebase Hosting preview domain during development.
- Keep generated local brainstorming files under `.superpowers/`, which is already ignored by git.
