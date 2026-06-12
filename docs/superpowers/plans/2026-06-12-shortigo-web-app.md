# ShortiGo Web App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a public React/Vite ShortiGo web app that mirrors the mobile app's TikTok-like shorts, catalog, auth, rewards, profile, and Firestore-backed social functionality.

**Architecture:** Create a separate `web/` React + TypeScript app, leaving `admin/` and the Flutter app intact. Keep Firebase setup, Firestore repositories, feature state, and UI components in focused modules; reuse ShortiGo colors/assets and the existing Firestore data model.

**Tech Stack:** React 18, TypeScript, Vite, Firebase Web SDK, React Router, Vitest, Testing Library, CSS modules/global CSS, browser `<video>`.

---

## File Structure

- Create `web/package.json`: scripts and dependencies for the consumer web app.
- Create `web/index.html`, `web/tsconfig*.json`, `web/vite.config.ts`, `web/vitest.setup.ts`: Vite/TypeScript/test setup.
- Create `web/.env.example`: Firebase and rewards API configuration names.
- Create `web/src/main.tsx`, `web/src/App.tsx`: app bootstrap and route tree.
- Create `web/src/firebase/firebase.ts`: Firebase initialization and config error handling.
- Create `web/src/domain/types.ts`: shared `Series`, `Episode`, `AppUser`, `Transaction`, and category types.
- Create `web/src/shared/format.ts`: compact counts, duration labels, date helpers.
- Create `web/src/shared/access.ts`: VIP/bonus/unlocked episode access decisions.
- Create `web/src/shared/share.ts`: ShortiGo share URL/text generation.
- Create `web/src/repositories/firestoreMappers.ts`: Firestore document-to-domain mapping.
- Create `web/src/repositories/catalogRepository.ts`: series/episode queries.
- Create `web/src/repositories/userRepository.ts`: user watch/create/update helpers.
- Create `web/src/repositories/socialRepository.ts`: like/save/follow/share transactions.
- Create `web/src/repositories/rewardsRepository.ts`: daily check-in and reward API/Firestore fallback.
- Create `web/src/app/AuthContext.tsx`: Firebase Auth/user document context.
- Create `web/src/app/AppShell.tsx`: responsive sidebar/top actions/layout.
- Create `web/src/app/RequireAuth.tsx`: route/action auth guard helpers.
- Create `web/src/components/*.tsx`: loading, error, empty, toast, modal, icon button, logo.
- Create `web/src/features/shorts/*`: shorts feed, video player, action rail, info panel, progress bar, locked state.
- Create `web/src/features/discover/*`: category tabs and series grid.
- Create `web/src/features/series/*`: series detail and direct episode player route.
- Create `web/src/features/auth/*`: login/signup page.
- Create `web/src/features/profile/*`: profile/wallet/transactions.
- Create `web/src/features/rewards/*`: rewards page.
- Create `web/src/features/my-list/*`: saved and followed series views.
- Create `web/src/styles.css`: ShortiGo responsive visual system.
- Modify `firebase.json` only after the app builds, preserving existing `hosting/public` behavior.
- Modify root `README.md` with web development instructions after implementation is verified.

---

### Task 1: Scaffold Consumer Web App

**Files:**
- Create: `web/package.json`
- Create: `web/index.html`
- Create: `web/tsconfig.json`
- Create: `web/tsconfig.node.json`
- Create: `web/vite.config.ts`
- Create: `web/vitest.setup.ts`
- Create: `web/.env.example`
- Create: `web/src/main.tsx`
- Create: `web/src/App.tsx`
- Create: `web/src/styles.css`

- [ ] **Step 1: Create the app package and config files**

Create `web/package.json`:

```json
{
  "name": "shortigo-web",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "preview": "vite preview",
    "test": "vitest run",
    "test:watch": "vitest"
  },
  "dependencies": {
    "@vitejs/plugin-react": "^4.3.1",
    "firebase": "^12.0.0",
    "lucide-react": "^0.468.0",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.26.2"
  },
  "devDependencies": {
    "@testing-library/jest-dom": "^6.4.8",
    "@testing-library/react": "^16.0.1",
    "@testing-library/user-event": "^14.5.2",
    "@types/react": "^18.3.3",
    "@types/react-dom": "^18.3.0",
    "jsdom": "^24.1.1",
    "typescript": "^5.5.4",
    "vite": "^5.3.4",
    "vitest": "^2.0.5"
  }
}
```

Create `web/index.html`:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="theme-color" content="#0B0613" />
    <title>ShortiGo</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

Create `web/tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["DOM", "DOM.Iterable", "ES2020"],
    "allowJs": false,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

Create `web/tsconfig.node.json`:

```json
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "allowSyntheticDefaultImports": true,
    "strict": true
  },
  "include": ["vite.config.ts"]
}
```

Create `web/vite.config.ts`:

```ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  test: {
    environment: "jsdom",
    globals: true,
    setupFiles: "./vitest.setup.ts",
  },
});
```

Create `web/vitest.setup.ts`:

```ts
import "@testing-library/jest-dom/vitest";
```

Create `web/.env.example`:

```text
VITE_FIREBASE_API_KEY=
VITE_FIREBASE_AUTH_DOMAIN=
VITE_FIREBASE_PROJECT_ID=shortigo-prod
VITE_FIREBASE_APP_ID=
VITE_FIREBASE_STORAGE_BUCKET=shortigo-prod.firebasestorage.app
VITE_REWARD_API_BASE_URL=
VITE_SHORTIGO_PUBLIC_ORIGIN=https://shortigo.app
```

- [ ] **Step 2: Create the minimal React bootstrap**

Create `web/src/main.tsx`:

```tsx
import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import { App } from "./App";
import "./styles.css";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>,
);
```

Create `web/src/App.tsx`:

```tsx
export function App() {
  return (
    <main className="app app--centered">
      <section className="boot-card">
        <img src="/branding/shortigo_launcher_icon.svg" alt="" />
        <h1>ShortiGo</h1>
        <p>Web app shell is ready.</p>
      </section>
    </main>
  );
}
```

Create `web/src/styles.css`:

```css
:root {
  --bg: #0b0613;
  --surface: #15101f;
  --surface-elevated: #1c1730;
  --divider: #2a2440;
  --primary: #8b5cf6;
  --primary-light: #a78bfa;
  --accent: #e879f9;
  --text: #f5f3ff;
  --text-secondary: #b4aed0;
  --text-muted: #7a7396;
  --success: #22c55e;
  --warning: #f59e0b;
  --error: #ef4444;
  --vip-gold: #ffd166;
  color-scheme: dark;
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

*,
*::before,
*::after {
  box-sizing: border-box;
}

body {
  margin: 0;
  min-width: 320px;
  min-height: 100vh;
  background: var(--bg);
  color: var(--text);
}

button,
input {
  font: inherit;
}

.app {
  min-height: 100vh;
}

.app--centered {
  display: grid;
  place-items: center;
  padding: 24px;
}

.boot-card {
  width: min(420px, 100%);
  border: 1px solid var(--divider);
  border-radius: 8px;
  background: var(--surface);
  padding: 28px;
  text-align: center;
}

.boot-card img {
  width: 76px;
  height: 76px;
}
```

- [ ] **Step 3: Copy brand assets for Vite public serving**

Run:

```bash
mkdir -p web/public/branding
cp assets/branding/shortigo_launcher_icon.svg web/public/branding/shortigo_launcher_icon.svg
cp assets/branding/splash_hero.png web/public/branding/splash_hero.png
```

Expected: `web/public/branding/shortigo_launcher_icon.svg` and `web/public/branding/splash_hero.png` exist.

- [ ] **Step 4: Install dependencies**

Run:

```bash
npm install --prefix web
```

Expected: npm installs packages and creates `web/package-lock.json`.

- [ ] **Step 5: Verify scaffold**

Run:

```bash
npm run build --prefix web
npm test --prefix web
```

Expected: build succeeds; tests report no tests found or pass once Vitest is configured.

- [ ] **Step 6: Commit scaffold**

```bash
git add web
git commit -m "feat(web): scaffold consumer app"
```

---

### Task 2: Domain Types And Shared Logic

**Files:**
- Create: `web/src/domain/types.ts`
- Create: `web/src/shared/format.ts`
- Create: `web/src/shared/access.ts`
- Create: `web/src/shared/share.ts`
- Test: `web/src/shared/format.test.ts`
- Test: `web/src/shared/access.test.ts`
- Test: `web/src/shared/share.test.ts`

- [ ] **Step 1: Write tests for shared logic**

Create `web/src/shared/format.test.ts`:

```ts
import { describe, expect, it } from "vitest";
import { compactCount, durationLabel } from "./format";

describe("format helpers", () => {
  it("formats compact counts", () => {
    expect(compactCount(0)).toBe("0");
    expect(compactCount(999)).toBe("999");
    expect(compactCount(1_200)).toBe("1.2K");
    expect(compactCount(242_600)).toBe("242.6K");
    expect(compactCount(1_500_000)).toBe("1.5M");
  });

  it("formats durations", () => {
    expect(durationLabel(45)).toBe("0:45");
    expect(durationLabel(125)).toBe("2:05");
    expect(durationLabel(3_725)).toBe("1:02:05");
  });
});
```

Create `web/src/shared/access.test.ts`:

```ts
import { describe, expect, it } from "vitest";
import { episodeAccess } from "./access";
import type { AppUser, Episode } from "../domain/types";

const openEpisode: Episode = {
  id: "e1",
  seriesId: "s1",
  order: 1,
  videoUrl: "https://example.com/v.mp4",
  thumbnailUrl: "https://example.com/t.jpg",
  durationSec: 30,
  isVipLocked: false,
  watchCount: 0,
  likeCount: 0,
  shareCount: 0,
};

const user: AppUser = {
  id: "u1",
  email: "u@example.com",
  isVip: false,
  coins: 0,
  bonus: 20,
  favoriteSeriesIds: [],
  unlockedEpisodeIds: [],
  likedEpisodeIds: [],
  followedSeriesIds: [],
  createdAt: new Date("2026-01-01T00:00:00Z"),
};

describe("episodeAccess", () => {
  it("opens public episodes", () => {
    expect(episodeAccess(openEpisode, null).state).toBe("open");
  });

  it("requires vip for locked episodes when user is not vip", () => {
    expect(episodeAccess({ ...openEpisode, isVipLocked: true }, user)).toEqual({
      state: "vip",
      bonusCost: undefined,
    });
  });

  it("opens vip episodes for vip users", () => {
    expect(
      episodeAccess({ ...openEpisode, isVipLocked: true }, { ...user, isVip: true }),
    ).toEqual({ state: "open" });
  });

  it("offers bonus unlock when configured", () => {
    expect(
      episodeAccess({ ...openEpisode, bonusUnlockCost: 12 }, user),
    ).toEqual({ state: "bonus", bonusCost: 12 });
  });

  it("opens episodes already unlocked by bonus", () => {
    expect(
      episodeAccess(
        { ...openEpisode, bonusUnlockCost: 12 },
        { ...user, unlockedEpisodeIds: ["e1"] },
      ),
    ).toEqual({ state: "open" });
  });
});
```

Create `web/src/shared/share.test.ts`:

```ts
import { describe, expect, it } from "vitest";
import { episodeShareText, episodeShareUrl } from "./share";

describe("share helpers", () => {
  it("builds stable episode URLs", () => {
    expect(
      episodeShareUrl({
        origin: "https://shortigo.app",
        seriesId: "series_1",
        episodeId: "episode_3",
      }),
    ).toBe("https://shortigo.app/series/series_1/episodes/episode_3");
  });

  it("builds share text", () => {
    expect(
      episodeShareText({
        seriesTitle: "Velvet Lies",
        episodeOrder: 3,
        seriesId: "series_1",
        episodeId: "episode_3",
        origin: "https://shortigo.app",
      }),
    ).toContain("Watch Velvet Lies EP.3 on ShortiGo");
  });
});
```

- [ ] **Step 2: Run tests to verify failure**

Run:

```bash
npm test --prefix web -- --run web/src/shared/format.test.ts web/src/shared/access.test.ts web/src/shared/share.test.ts
```

Expected: fails because modules do not exist.

- [ ] **Step 3: Implement domain types**

Create `web/src/domain/types.ts`:

```ts
export type CategoryId =
  | "forYou"
  | "new"
  | "hot"
  | "adventure"
  | "scary"
  | "anime"
  | "vip";

export type Series = {
  id: string;
  title: string;
  description: string;
  coverUrl: string;
  category: CategoryId;
  isVip: boolean;
  episodeCount: number;
  totalDurationSec: number;
  createdAt: Date;
  popularity: number;
  watchCount: number;
  saveCount: number;
  followerCount: number;
  isPublished: boolean;
};

export type Episode = {
  id: string;
  seriesId: string;
  order: number;
  videoUrl: string;
  thumbnailUrl: string;
  durationSec: number;
  isVipLocked: boolean;
  bonusUnlockCost?: number;
  watchCount: number;
  likeCount: number;
  shareCount: number;
};

export type AppUser = {
  id: string;
  email: string;
  displayName?: string;
  photoUrl?: string;
  isVip: boolean;
  vipExpiresAt?: Date;
  coins: number;
  bonus: number;
  favoriteSeriesIds: string[];
  unlockedEpisodeIds: string[];
  likedEpisodeIds: string[];
  followedSeriesIds: string[];
  lastDailyCheckIn?: Date;
  createdAt: Date;
};

export type WalletTransaction = {
  id: string;
  userId: string;
  type: string;
  amount: number;
  balanceType: "coins" | "bonus";
  createdAt: Date;
  description?: string;
};

export const categories: { id: CategoryId; label: string }[] = [
  { id: "forYou", label: "For You" },
  { id: "new", label: "New" },
  { id: "hot", label: "Hot" },
  { id: "adventure", label: "Adventure" },
  { id: "scary", label: "Scary" },
  { id: "anime", label: "Anime" },
  { id: "vip", label: "VIP" },
];
```

- [ ] **Step 4: Implement shared helpers**

Create `web/src/shared/format.ts`:

```ts
export function compactCount(value: number): string {
  const abs = Math.abs(value);
  if (abs < 1_000) return String(value);
  if (abs < 1_000_000) return trimCompact(value / 1_000, "K");
  return trimCompact(value / 1_000_000, "M");
}

function trimCompact(value: number, suffix: string): string {
  const rounded = Math.round(value * 10) / 10;
  return `${Number.isInteger(rounded) ? rounded.toFixed(0) : rounded.toFixed(1)}${suffix}`;
}

export function durationLabel(totalSeconds: number): string {
  const safe = Math.max(0, Math.floor(totalSeconds));
  const hours = Math.floor(safe / 3600);
  const minutes = Math.floor((safe % 3600) / 60);
  const seconds = safe % 60;
  const mm = hours > 0 ? String(minutes).padStart(2, "0") : String(minutes);
  const ss = String(seconds).padStart(2, "0");
  return hours > 0 ? `${hours}:${mm}:${ss}` : `${mm}:${ss}`;
}
```

Create `web/src/shared/access.ts`:

```ts
import type { AppUser, Episode } from "../domain/types";

export type EpisodeAccess =
  | { state: "open" }
  | { state: "login"; bonusCost?: number }
  | { state: "bonus"; bonusCost: number }
  | { state: "vip"; bonusCost?: number };

export function episodeAccess(episode: Episode, user: AppUser | null): EpisodeAccess {
  if (user?.unlockedEpisodeIds.includes(episode.id)) {
    return { state: "open" };
  }
  if (episode.isVipLocked) {
    return user?.isVip ? { state: "open" } : { state: "vip", bonusCost: episode.bonusUnlockCost };
  }
  if (episode.bonusUnlockCost && episode.bonusUnlockCost > 0) {
    if (!user) return { state: "login", bonusCost: episode.bonusUnlockCost };
    return { state: "bonus", bonusCost: episode.bonusUnlockCost };
  }
  return { state: "open" };
}
```

Create `web/src/shared/share.ts`:

```ts
type EpisodeShareUrlInput = {
  origin: string;
  seriesId: string;
  episodeId: string;
};

type EpisodeShareTextInput = EpisodeShareUrlInput & {
  seriesTitle: string;
  episodeOrder: number;
};

export function episodeShareUrl({ origin, seriesId, episodeId }: EpisodeShareUrlInput): string {
  const base = origin.replace(/\/+$/, "");
  return `${base}/series/${encodeURIComponent(seriesId)}/episodes/${encodeURIComponent(episodeId)}`;
}

export function episodeShareText(input: EpisodeShareTextInput): string {
  return `Watch ${input.seriesTitle} EP.${input.episodeOrder} on ShortiGo: ${episodeShareUrl(input)}`;
}
```

- [ ] **Step 5: Run tests**

Run:

```bash
npm test --prefix web -- --run web/src/shared/format.test.ts web/src/shared/access.test.ts web/src/shared/share.test.ts
```

Expected: all tests pass.

- [ ] **Step 6: Commit shared logic**

```bash
git add web/src/domain web/src/shared
git commit -m "feat(web): add domain and shared helpers"
```

---

### Task 3: Firebase Setup And Firestore Mappers

**Files:**
- Create: `web/src/firebase/firebase.ts`
- Create: `web/src/repositories/firestoreMappers.ts`
- Test: `web/src/repositories/firestoreMappers.test.ts`

- [ ] **Step 1: Write mapper tests**

Create `web/src/repositories/firestoreMappers.test.ts`:

```ts
import { Timestamp } from "firebase/firestore";
import { describe, expect, it } from "vitest";
import { mapEpisode, mapSeries, mapUser } from "./firestoreMappers";

describe("firestore mappers", () => {
  it("maps series documents with defaults", () => {
    expect(
      mapSeries("s1", {
        title: "Velvet Lies",
        coverUrl: "https://example.com/c.jpg",
        category: "hot",
        createdAt: Timestamp.fromDate(new Date("2026-01-01T00:00:00Z")),
      }),
    ).toMatchObject({
      id: "s1",
      title: "Velvet Lies",
      description: "",
      category: "hot",
      isPublished: true,
      saveCount: 0,
    });
  });

  it("maps episode documents with defaults", () => {
    expect(
      mapEpisode("e1", {
        seriesId: "s1",
        order: 2,
        videoUrl: "https://example.com/v.mp4",
        thumbnailUrl: "https://example.com/t.jpg",
        durationSec: 33,
      }),
    ).toMatchObject({
      id: "e1",
      seriesId: "s1",
      order: 2,
      isVipLocked: false,
      likeCount: 0,
    });
  });

  it("maps users with list defaults", () => {
    expect(
      mapUser("u1", {
        email: "u@example.com",
        createdAt: Timestamp.fromDate(new Date("2026-01-01T00:00:00Z")),
      }),
    ).toMatchObject({
      id: "u1",
      email: "u@example.com",
      coins: 0,
      bonus: 0,
      favoriteSeriesIds: [],
    });
  });
});
```

- [ ] **Step 2: Run mapper tests to verify failure**

Run:

```bash
npm test --prefix web -- --run web/src/repositories/firestoreMappers.test.ts
```

Expected: fails because `firestoreMappers.ts` does not exist.

- [ ] **Step 3: Implement Firebase initialization**

Create `web/src/firebase/firebase.ts`:

```ts
import { initializeApp, type FirebaseApp } from "firebase/app";
import { getAuth, type Auth } from "firebase/auth";
import { getFirestore, type Firestore } from "firebase/firestore";

const requiredEnv = [
  "VITE_FIREBASE_API_KEY",
  "VITE_FIREBASE_AUTH_DOMAIN",
  "VITE_FIREBASE_PROJECT_ID",
  "VITE_FIREBASE_APP_ID",
] as const;

export const firebaseConfigError = requiredEnv.find((key) => !import.meta.env[key]);

export const publicOrigin =
  import.meta.env.VITE_SHORTIGO_PUBLIC_ORIGIN || "https://shortigo.app";

export const rewardApiBaseUrl = import.meta.env.VITE_REWARD_API_BASE_URL || "";

let app: FirebaseApp | null = null;

if (!firebaseConfigError) {
  app = initializeApp({
    apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
    authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
    projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
    appId: import.meta.env.VITE_FIREBASE_APP_ID,
    storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  });
}

export const auth: Auth | null = app ? getAuth(app) : null;
export const db: Firestore | null = app ? getFirestore(app) : null;
```

- [ ] **Step 4: Implement Firestore mappers**

Create `web/src/repositories/firestoreMappers.ts`:

```ts
import { Timestamp } from "firebase/firestore";
import type { AppUser, CategoryId, Episode, Series, WalletTransaction } from "../domain/types";

type Raw = Record<string, unknown>;

export function mapSeries(id: string, data: Raw): Series {
  return {
    id,
    title: stringValue(data.title),
    description: stringValue(data.description),
    coverUrl: stringValue(data.coverUrl),
    category: categoryValue(data.category),
    isVip: booleanValue(data.isVip, false),
    episodeCount: numberValue(data.episodeCount),
    totalDurationSec: numberValue(data.totalDurationSec),
    createdAt: dateValue(data.createdAt),
    popularity: numberValue(data.popularity),
    watchCount: numberValue(data.watchCount),
    saveCount: numberValue(data.saveCount),
    followerCount: numberValue(data.followerCount),
    isPublished: booleanValue(data.isPublished, true),
  };
}

export function mapEpisode(id: string, data: Raw): Episode {
  const bonusUnlockCost = optionalNumber(data.bonusUnlockCost);
  return {
    id,
    seriesId: stringValue(data.seriesId),
    order: numberValue(data.order),
    videoUrl: stringValue(data.videoUrl),
    thumbnailUrl: stringValue(data.thumbnailUrl),
    durationSec: numberValue(data.durationSec),
    isVipLocked: booleanValue(data.isVipLocked, false),
    ...(bonusUnlockCost === undefined ? {} : { bonusUnlockCost }),
    watchCount: numberValue(data.watchCount),
    likeCount: numberValue(data.likeCount),
    shareCount: numberValue(data.shareCount),
  };
}

export function mapUser(id: string, data: Raw): AppUser {
  return {
    id,
    email: stringValue(data.email),
    displayName: optionalString(data.displayName),
    photoUrl: optionalString(data.photoUrl),
    isVip: booleanValue(data.isVip, false),
    vipExpiresAt: optionalDate(data.vipExpiresAt),
    coins: numberValue(data.coins),
    bonus: numberValue(data.bonus),
    favoriteSeriesIds: stringList(data.favoriteSeriesIds),
    unlockedEpisodeIds: stringList(data.unlockedEpisodeIds),
    likedEpisodeIds: stringList(data.likedEpisodeIds),
    followedSeriesIds: stringList(data.followedSeriesIds),
    lastDailyCheckIn: optionalDate(data.lastDailyCheckIn),
    createdAt: dateValue(data.createdAt),
  };
}

export function mapTransaction(id: string, data: Raw): WalletTransaction {
  return {
    id,
    userId: stringValue(data.userId),
    type: stringValue(data.type),
    amount: numberValue(data.amount),
    balanceType: data.balanceType === "coins" ? "coins" : "bonus",
    createdAt: dateValue(data.createdAt),
    description: optionalString(data.description),
  };
}

function stringValue(value: unknown): string {
  return typeof value === "string" ? value : "";
}

function optionalString(value: unknown): string | undefined {
  return typeof value === "string" && value.length > 0 ? value : undefined;
}

function numberValue(value: unknown): number {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

function optionalNumber(value: unknown): number | undefined {
  return typeof value === "number" && Number.isFinite(value) ? value : undefined;
}

function booleanValue(value: unknown, fallback: boolean): boolean {
  return typeof value === "boolean" ? value : fallback;
}

function categoryValue(value: unknown): CategoryId {
  const allowed = new Set(["forYou", "new", "hot", "adventure", "scary", "anime", "vip"]);
  return typeof value === "string" && allowed.has(value) ? (value as CategoryId) : "new";
}

function stringList(value: unknown): string[] {
  return Array.isArray(value) ? value.filter((item): item is string => typeof item === "string") : [];
}

function dateValue(value: unknown): Date {
  return optionalDate(value) ?? new Date(0);
}

function optionalDate(value: unknown): Date | undefined {
  if (value instanceof Date) return value;
  if (value instanceof Timestamp) return value.toDate();
  if (value && typeof value === "object" && "toDate" in value && typeof value.toDate === "function") {
    return value.toDate();
  }
  return undefined;
}
```

- [ ] **Step 5: Run mapper tests**

Run:

```bash
npm test --prefix web -- --run web/src/repositories/firestoreMappers.test.ts
```

Expected: all mapper tests pass.

- [ ] **Step 6: Commit Firebase foundation**

```bash
git add web/src/firebase web/src/repositories/firestoreMappers.ts web/src/repositories/firestoreMappers.test.ts
git commit -m "feat(web): add firebase setup and mappers"
```

---

### Task 4: Catalog, User, Social, And Rewards Repositories

**Files:**
- Create: `web/src/repositories/catalogRepository.ts`
- Create: `web/src/repositories/userRepository.ts`
- Create: `web/src/repositories/socialRepository.ts`
- Create: `web/src/repositories/rewardsRepository.ts`
- Test: `web/src/repositories/catalogRepository.test.ts`
- Test: `web/src/repositories/socialRepository.test.ts`
- Test: `web/src/repositories/rewardsRepository.test.ts`

- [ ] **Step 1: Write repository unit tests for pure query/action helpers**

Create `web/src/repositories/catalogRepository.test.ts`:

```ts
import { describe, expect, it } from "vitest";
import { categoryQuerySpec, orderedFeaturedIds } from "./catalogRepository";

describe("catalogRepository helpers", () => {
  it("keeps featured IDs ordered and limited", () => {
    expect(orderedFeaturedIds(["b", "a", "c"], new Set(["a", "c"]), 2)).toEqual(["a", "c"]);
  });

  it("builds hot category query spec", () => {
    expect(categoryQuerySpec("hot")).toEqual({
      field: "category",
      op: "==",
      value: "hot",
      orderField: "popularity",
      direction: "desc",
    });
  });

  it("builds vip category query spec", () => {
    expect(categoryQuerySpec("vip")).toEqual({
      field: "isVip",
      op: "==",
      value: true,
      orderField: "createdAt",
      direction: "desc",
    });
  });

  it("chunks ids for Firestore in queries", () => {
    expect(chunkIds(["1", "2", "3"], 2)).toEqual([["1", "2"], ["3"]]);
  });
});
```

Create `web/src/repositories/socialRepository.test.ts`:

```ts
import { describe, expect, it } from "vitest";
import { nextCount, toggleArray } from "./socialRepository";

describe("socialRepository helpers", () => {
  it("toggles arrays", () => {
    expect(toggleArray(["a"], "b", true)).toEqual(["a", "b"]);
    expect(toggleArray(["a"], "a", true)).toEqual(["a"]);
    expect(toggleArray(["a", "b"], "a", false)).toEqual(["b"]);
  });

  it("does not decrement counts below zero", () => {
    expect(nextCount(0, -1)).toBe(0);
    expect(nextCount(4, -1)).toBe(3);
    expect(nextCount(4, 1)).toBe(5);
  });
});
```

Create `web/src/repositories/rewardsRepository.test.ts`:

```ts
import { describe, expect, it } from "vitest";
import { shouldUseRewardApi, canClaimDailyCheckIn } from "./rewardsRepository";

describe("rewardsRepository helpers", () => {
  it("uses reward api only when configured", () => {
    expect(shouldUseRewardApi("")).toBe(false);
    expect(shouldUseRewardApi("https://api.example.com")).toBe(true);
  });

  it("allows daily check-in once per local day", () => {
    const now = new Date("2026-06-12T10:00:00Z");
    expect(canClaimDailyCheckIn(undefined, now)).toBe(true);
    expect(canClaimDailyCheckIn(new Date("2026-06-11T23:00:00Z"), now)).toBe(true);
    expect(canClaimDailyCheckIn(new Date("2026-06-12T01:00:00Z"), now)).toBe(false);
  });
});
```

- [ ] **Step 2: Run tests to verify failure**

Run:

```bash
npm test --prefix web -- --run web/src/repositories/catalogRepository.test.ts web/src/repositories/socialRepository.test.ts web/src/repositories/rewardsRepository.test.ts
```

Expected: fails because repositories do not exist.

- [ ] **Step 3: Implement catalog repository**

Create `web/src/repositories/catalogRepository.ts`:

```ts
import {
  collection,
  doc,
  documentId,
  getDoc,
  getDocs,
  limit as limitQuery,
  orderBy,
  query,
  where,
  type Firestore,
  type WhereFilterOp,
} from "firebase/firestore";
import type { CategoryId, Episode, Series } from "../domain/types";
import { mapEpisode, mapSeries } from "./firestoreMappers";

export type CategoryQuerySpec = {
  field: string;
  op: WhereFilterOp;
  value: string | boolean;
  orderField: string;
  direction: "asc" | "desc";
};

export function categoryQuerySpec(category: Exclude<CategoryId, "forYou">): CategoryQuerySpec {
  if (category === "vip") {
    return { field: "isVip", op: "==", value: true, orderField: "createdAt", direction: "desc" };
  }
  return {
    field: "category",
    op: "==",
    value: category,
    orderField: category === "hot" ? "popularity" : "createdAt",
    direction: "desc",
  };
}

export function orderedFeaturedIds(ids: string[], available: Set<string>, max: number): string[] {
  return ids.filter((id) => available.has(id)).slice(0, max);
}

export function chunkIds(ids: string[], size = 10): string[][] {
  const chunks: string[][] = [];
  for (let index = 0; index < ids.length; index += size) {
    chunks.push(ids.slice(index, index + size));
  }
  return chunks;
}

export async function fetchForYouSeries(db: Firestore, max = 20): Promise<Series[]> {
  const featured = await getDoc(doc(db, "admin", "featured"));
  const ids = Array.isArray(featured.data()?.seriesIds)
    ? featured.data()!.seriesIds.filter((id: unknown): id is string => typeof id === "string")
    : [];
  if (ids.length === 0) return [];

  const chunks = chunkIds(ids, 10);
  const docs = await Promise.all(
    chunks.map((part) =>
      getDocs(query(collection(db, "series"), where(documentId(), "in", part))),
    ),
  );
  const byId = new Map(
    docs
      .flatMap((snap) => snap.docs)
      .map((item) => [item.id, mapSeries(item.id, item.data())] as const),
  );
  return orderedFeaturedIds(ids, new Set(byId.keys()), max)
    .map((id) => byId.get(id)!)
    .filter((series) => series.isPublished);
}

export async function fetchSeriesByCategory(
  db: Firestore,
  category: CategoryId,
  max = 20,
): Promise<Series[]> {
  if (category === "forYou") return fetchForYouSeries(db, max);
  const spec = categoryQuerySpec(category);
  const snap = await getDocs(
    query(
      collection(db, "series"),
      where("isPublished", "==", true),
      where(spec.field, spec.op, spec.value),
      orderBy(spec.orderField, spec.direction),
      limitQuery(max),
    ),
  );
  return snap.docs.map((item) => mapSeries(item.id, item.data()));
}

export async function fetchSeriesById(db: Firestore, seriesId: string): Promise<Series | null> {
  const snap = await getDoc(doc(db, "series", seriesId));
  return snap.exists() ? mapSeries(snap.id, snap.data()) : null;
}

export async function fetchSeriesByIds(db: Firestore, ids: string[]): Promise<Series[]> {
  const uniqueIds = [...new Set(ids)].filter(Boolean);
  if (uniqueIds.length === 0) return [];
  const snaps = await Promise.all(
    chunkIds(uniqueIds, 10).map((part) =>
      getDocs(query(collection(db, "series"), where(documentId(), "in", part))),
    ),
  );
  const byId = new Map(
    snaps
      .flatMap((snap) => snap.docs)
      .map((item) => [item.id, mapSeries(item.id, item.data())] as const),
  );
  return uniqueIds.map((id) => byId.get(id)).filter((item): item is Series => Boolean(item));
}

export async function fetchEpisodesBySeriesId(db: Firestore, seriesId: string): Promise<Episode[]> {
  const snap = await getDocs(
    query(collection(db, "episodes"), where("seriesId", "==", seriesId), orderBy("order", "asc")),
  );
  return snap.docs.map((item) => mapEpisode(item.id, item.data()));
}

export async function fetchEpisodeById(db: Firestore, episodeId: string): Promise<Episode | null> {
  const snap = await getDoc(doc(db, "episodes", episodeId));
  return snap.exists() ? mapEpisode(snap.id, snap.data()) : null;
}

```

- [ ] **Step 4: Implement user, social, and reward repositories**

Create `web/src/repositories/userRepository.ts`:

```ts
import {
  collection,
  doc,
  getDoc,
  getDocs,
  limit,
  onSnapshot,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  type Firestore,
  type Unsubscribe,
} from "firebase/firestore";
import type { User } from "firebase/auth";
import type { AppUser, WalletTransaction } from "../domain/types";
import { mapTransaction, mapUser } from "./firestoreMappers";

export function watchAppUser(
  db: Firestore,
  uid: string,
  onNext: (user: AppUser | null) => void,
  onError: (error: Error) => void,
): Unsubscribe {
  return onSnapshot(
    doc(db, "users", uid),
    (snapshot) => onNext(snapshot.exists() ? mapUser(snapshot.id, snapshot.data()) : null),
    onError,
  );
}

export async function ensureUserDoc(db: Firestore, authUser: User): Promise<void> {
  const ref = doc(db, "users", authUser.uid);
  const existing = await getDoc(ref);
  if (existing.exists()) return;
  await setDoc(ref, {
    id: authUser.uid,
    email: authUser.email ?? "",
    displayName: authUser.displayName ?? null,
    photoUrl: authUser.photoURL ?? null,
    isVip: false,
    vipExpiresAt: null,
    coins: 0,
    bonus: 0,
    favoriteSeriesIds: [],
    unlockedEpisodeIds: [],
    likedEpisodeIds: [],
    followedSeriesIds: [],
    createdAt: serverTimestamp(),
  });
}

export async function fetchTransactions(db: Firestore, uid: string): Promise<WalletTransaction[]> {
  const snap = await getDocs(
    query(collection(db, "users", uid, "transactions"), orderBy("createdAt", "desc"), limit(25)),
  );
  return snap.docs.map((item) => mapTransaction(item.id, item.data()));
}
```

Create `web/src/repositories/socialRepository.ts`:

```ts
import {
  doc,
  runTransaction,
  type Firestore,
} from "firebase/firestore";

export function toggleArray(items: string[], id: string, enabled: boolean): string[] {
  if (enabled) return items.includes(id) ? items : [...items, id];
  return items.filter((item) => item !== id);
}

export function nextCount(current: unknown, delta: number): number {
  const count = typeof current === "number" ? current : 0;
  return Math.max(0, count + delta);
}

export async function setEpisodeLiked(
  db: Firestore,
  userId: string,
  episodeId: string,
  liked: boolean,
): Promise<void> {
  const userRef = doc(db, "users", userId);
  const episodeRef = doc(db, "episodes", episodeId);
  await runTransaction(db, async (transaction) => {
    const user = await transaction.get(userRef);
    const episode = await transaction.get(episodeRef);
    const likedIds = stringList(user.data()?.likedEpisodeIds);
    const alreadyLiked = likedIds.includes(episodeId);
    if (liked === alreadyLiked) return;
    transaction.update(userRef, { likedEpisodeIds: toggleArray(likedIds, episodeId, liked) });
    transaction.update(episodeRef, { likeCount: nextCount(episode.data()?.likeCount, liked ? 1 : -1) });
  });
}

export async function setSeriesSaved(
  db: Firestore,
  userId: string,
  seriesId: string,
  saved: boolean,
): Promise<void> {
  const userRef = doc(db, "users", userId);
  const seriesRef = doc(db, "series", seriesId);
  await runTransaction(db, async (transaction) => {
    const user = await transaction.get(userRef);
    const series = await transaction.get(seriesRef);
    const savedIds = stringList(user.data()?.favoriteSeriesIds);
    const alreadySaved = savedIds.includes(seriesId);
    if (saved === alreadySaved) return;
    transaction.update(userRef, { favoriteSeriesIds: toggleArray(savedIds, seriesId, saved) });
    transaction.update(seriesRef, { saveCount: nextCount(series.data()?.saveCount, saved ? 1 : -1) });
  });
}

export async function setSeriesFollowed(
  db: Firestore,
  userId: string,
  seriesId: string,
  followed: boolean,
): Promise<void> {
  const userRef = doc(db, "users", userId);
  const seriesRef = doc(db, "series", seriesId);
  await runTransaction(db, async (transaction) => {
    const user = await transaction.get(userRef);
    const series = await transaction.get(seriesRef);
    const followedIds = stringList(user.data()?.followedSeriesIds);
    const alreadyFollowed = followedIds.includes(seriesId);
    if (followed === alreadyFollowed) return;
    transaction.update(userRef, { followedSeriesIds: toggleArray(followedIds, seriesId, followed) });
    transaction.update(seriesRef, { followerCount: nextCount(series.data()?.followerCount, followed ? 1 : -1) });
  });
}

export async function recordEpisodeShare(db: Firestore, episodeId: string): Promise<void> {
  const episodeRef = doc(db, "episodes", episodeId);
  await runTransaction(db, async (transaction) => {
    const episode = await transaction.get(episodeRef);
    transaction.update(episodeRef, { shareCount: nextCount(episode.data()?.shareCount, 1) });
  });
}

function stringList(value: unknown): string[] {
  return Array.isArray(value) ? value.filter((item): item is string => typeof item === "string") : [];
}
```

Create `web/src/repositories/rewardsRepository.ts`:

```ts
import {
  collection,
  doc,
  increment,
  runTransaction,
  serverTimestamp,
  setDoc,
  type Firestore,
} from "firebase/firestore";
import type { Auth } from "firebase/auth";

export function shouldUseRewardApi(baseUrl: string): boolean {
  return baseUrl.trim().length > 0;
}

export function canClaimDailyCheckIn(lastDailyCheckIn: Date | undefined, now = new Date()): boolean {
  if (!lastDailyCheckIn) return true;
  return lastDailyCheckIn.toDateString() !== now.toDateString();
}

export async function claimDailyCheckIn(params: {
  db: Firestore;
  auth: Auth;
  userId: string;
  rewardApiBaseUrl: string;
}): Promise<void> {
  if (shouldUseRewardApi(params.rewardApiBaseUrl)) {
    const token = await params.auth.currentUser?.getIdToken();
    const response = await fetch(`${params.rewardApiBaseUrl.replace(/\/+$/, "")}/daily-check-in`, {
      method: "POST",
      headers: token ? { Authorization: `Bearer ${token}` } : {},
    });
    if (!response.ok) throw new Error("Daily check-in failed");
    return;
  }

  const userRef = doc(params.db, "users", params.userId);
  const transactionRef = doc(collection(params.db, "users", params.userId, "transactions"));
  await runTransaction(params.db, async (transaction) => {
    const user = await transaction.get(userRef);
    const last = user.data()?.lastDailyCheckIn;
    const lastDate = last && typeof last.toDate === "function" ? last.toDate() : undefined;
    if (!canClaimDailyCheckIn(lastDate)) return;
    transaction.update(userRef, {
      bonus: increment(12),
      lastDailyCheckIn: serverTimestamp(),
    });
    transaction.set(transactionRef, {
      userId: params.userId,
      type: "daily_check_in",
      amount: 12,
      balanceType: "bonus",
      description: "Daily check-in",
      createdAt: serverTimestamp(),
    });
  });
}

export async function grantWebAdReward(db: Firestore, userId: string): Promise<void> {
  const transactionRef = doc(collection(db, "users", userId, "transactions"));
  await setDoc(transactionRef, {
    userId,
    type: "web_reward",
    amount: 12,
    balanceType: "bonus",
    description: "Web reward",
    createdAt: serverTimestamp(),
  });
  await runTransaction(db, async (transaction) => {
    const userRef = doc(db, "users", userId);
    transaction.update(userRef, { bonus: increment(12) });
  });
}
```

- [ ] **Step 5: Run repository tests**

Run:

```bash
npm test --prefix web -- --run web/src/repositories/catalogRepository.test.ts web/src/repositories/socialRepository.test.ts web/src/repositories/rewardsRepository.test.ts
```

Expected: all tests pass.

- [ ] **Step 6: Commit repositories**

```bash
git add web/src/repositories
git commit -m "feat(web): add firestore repositories"
```

---

### Task 5: Auth Context, Shell, And Base Components

**Files:**
- Create: `web/src/app/AuthContext.tsx`
- Create: `web/src/app/AppShell.tsx`
- Create: `web/src/app/RequireAuth.tsx`
- Create: `web/src/components/ShortiGoLogo.tsx`
- Create: `web/src/components/LoadingView.tsx`
- Create: `web/src/components/ErrorView.tsx`
- Create: `web/src/components/EmptyView.tsx`
- Create: `web/src/components/Toast.tsx`
- Modify: `web/src/App.tsx`
- Modify: `web/src/styles.css`
- Test: `web/src/app/AppShell.test.tsx`

- [ ] **Step 1: Write shell render test**

Create `web/src/app/AppShell.test.tsx`:

```tsx
import { render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { describe, expect, it } from "vitest";
import { AppShell } from "./AppShell";

describe("AppShell", () => {
  it("renders primary navigation", () => {
    render(
      <MemoryRouter>
        <AppShell>
          <div>Current page</div>
        </AppShell>
      </MemoryRouter>,
    );

    expect(screen.getByText("ShortiGo")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /for you/i })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /explore/i })).toBeInTheDocument();
    expect(screen.getByText("Current page")).toBeInTheDocument();
  });
});
```

- [ ] **Step 2: Run shell test to verify failure**

Run:

```bash
npm test --prefix web -- --run web/src/app/AppShell.test.tsx
```

Expected: fails because `AppShell` does not exist.

- [ ] **Step 3: Implement auth context and app shell**

Create `web/src/app/AuthContext.tsx`:

```tsx
import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from "react";
import { onAuthStateChanged, type User } from "firebase/auth";
import type { AppUser } from "../domain/types";
import { auth, db } from "../firebase/firebase";
import { ensureUserDoc, watchAppUser } from "../repositories/userRepository";

type AuthContextValue = {
  firebaseUser: User | null;
  appUser: AppUser | null;
  loading: boolean;
  configReady: boolean;
};

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [firebaseUser, setFirebaseUser] = useState<User | null>(null);
  const [appUser, setAppUser] = useState<AppUser | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!auth || !db) {
      setLoading(false);
      return;
    }
    return onAuthStateChanged(auth, async (user) => {
      setFirebaseUser(user);
      setAppUser(null);
      if (!user) {
        setLoading(false);
        return;
      }
      await ensureUserDoc(db, user);
      const unsubscribe = watchAppUser(db, user.uid, setAppUser, () => setAppUser(null));
      setLoading(false);
      return unsubscribe;
    });
  }, []);

  const value = useMemo(
    () => ({ firebaseUser, appUser, loading, configReady: Boolean(auth && db) }),
    [firebaseUser, appUser, loading],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const value = useContext(AuthContext);
  if (!value) throw new Error("useAuth must be used inside AuthProvider");
  return value;
}
```

Create `web/src/app/AppShell.tsx`:

```tsx
import { Bookmark, Compass, Gift, Heart, Home, Search, UserRound, UsersRound } from "lucide-react";
import { NavLink } from "react-router-dom";
import { ShortiGoLogo } from "../components/ShortiGoLogo";
import { useAuth } from "./AuthContext";

const nav = [
  { to: "/shorts", label: "For You", icon: Home },
  { to: "/discover", label: "Explore", icon: Compass },
  { to: "/following", label: "Following", icon: UsersRound },
  { to: "/rewards", label: "Rewards", icon: Gift },
  { to: "/my-list", label: "My List", icon: Bookmark },
  { to: "/profile", label: "Profile", icon: UserRound },
];

export function AppShell({ children }: { children: React.ReactNode }) {
  const { appUser } = useAuth();

  return (
    <div className="app-shell">
      <aside className="sidebar" aria-label="Primary">
        <ShortiGoLogo />
        <label className="search-box">
          <Search size={18} aria-hidden="true" />
          <input aria-label="Search series" />
        </label>
        <nav className="side-nav">
          {nav.map((item) => (
            <NavLink key={item.to} to={item.to} className={({ isActive }) => `side-nav__link ${isActive ? "is-active" : ""}`}>
              <item.icon size={24} aria-hidden="true" />
              <span>{item.label}</span>
            </NavLink>
          ))}
        </nav>
      </aside>
      <main className="shell-main">{children}</main>
      <div className="top-actions">
        {appUser ? (
          <NavLink to="/profile" className="wallet-pill">
            <Heart size={17} aria-hidden="true" />
            {appUser.bonus} bonus
          </NavLink>
        ) : (
          <NavLink to="/login" className="primary-pill">Log in</NavLink>
        )}
      </div>
    </div>
  );
}
```

Create `web/src/app/RequireAuth.tsx`:

```tsx
import { Navigate, useLocation } from "react-router-dom";
import { LoadingView } from "../components/LoadingView";
import { useAuth } from "./AuthContext";

export function RequireAuth({ children }: { children: React.ReactNode }) {
  const auth = useAuth();
  const location = useLocation();

  if (auth.loading) return <LoadingView label="Checking account" />;
  if (!auth.firebaseUser) return <Navigate to="/login" state={{ from: location.pathname }} replace />;
  return <>{children}</>;
}
```

- [ ] **Step 4: Implement base components**

Create `web/src/components/ShortiGoLogo.tsx`:

```tsx
import { Link } from "react-router-dom";

export function ShortiGoLogo() {
  return (
    <Link to="/shorts" className="logo" aria-label="ShortiGo home">
      <img src="/branding/shortigo_launcher_icon.svg" alt="" />
      <span>ShortiGo</span>
    </Link>
  );
}
```

Create `web/src/components/LoadingView.tsx`:

```tsx
export function LoadingView({ label = "Loading" }: { label?: string }) {
  return (
    <div className="state-view" role="status">
      <span className="spinner" />
      <p>{label}</p>
    </div>
  );
}
```

Create `web/src/components/ErrorView.tsx`:

```tsx
export function ErrorView({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return (
    <div className="state-view state-view--error">
      <h2>Something went wrong</h2>
      <p>{message}</p>
      {onRetry ? <button className="primary-pill" onClick={onRetry}>Retry</button> : null}
    </div>
  );
}
```

Create `web/src/components/EmptyView.tsx`:

```tsx
export function EmptyView({ title, message }: { title: string; message: string }) {
  return (
    <div className="state-view">
      <h2>{title}</h2>
      <p>{message}</p>
    </div>
  );
}
```

Create `web/src/components/Toast.tsx`:

```tsx
import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from "react";

type Toast = { id: number; message: string; tone: "info" | "error" | "success" };
type ToastContextValue = { showToast: (message: string, tone?: Toast["tone"]) => void };
const ToastContext = createContext<ToastContextValue | null>(null);

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);
  const showToast = useCallback((message: string, tone: Toast["tone"] = "info") => {
    const id = Date.now();
    setToasts((items) => [...items, { id, message, tone }]);
    window.setTimeout(() => setToasts((items) => items.filter((item) => item.id !== id)), 3500);
  }, []);
  const value = useMemo(() => ({ showToast }), [showToast]);

  return (
    <ToastContext.Provider value={value}>
      {children}
      <div className="toast-stack" aria-live="polite">
        {toasts.map((toast) => (
          <div key={toast.id} className={`toast toast--${toast.tone}`}>{toast.message}</div>
        ))}
      </div>
    </ToastContext.Provider>
  );
}

export function useToast() {
  const value = useContext(ToastContext);
  if (!value) throw new Error("useToast must be used inside ToastProvider");
  return value;
}
```

- [ ] **Step 5: Wire providers and temporary route screens**

Replace `web/src/App.tsx` with:

```tsx
import { Navigate, Route, Routes } from "react-router-dom";
import { AppShell } from "./app/AppShell";
import { AuthProvider } from "./app/AuthContext";
import { ToastProvider } from "./components/Toast";

function TemporaryPage({ title }: { title: string }) {
  return (
    <section className="page-surface">
      <h1>{title}</h1>
    </section>
  );
}

export function App() {
  return (
    <AuthProvider>
      <ToastProvider>
        <Routes>
          <Route path="/" element={<Navigate to="/shorts" replace />} />
          <Route
            path="*"
            element={
              <AppShell>
                <Routes>
                  <Route path="/shorts" element={<TemporaryPage title="Shorts" />} />
                  <Route path="/discover" element={<TemporaryPage title="Explore" />} />
                  <Route path="/following" element={<TemporaryPage title="Following" />} />
                  <Route path="/rewards" element={<TemporaryPage title="Rewards" />} />
                  <Route path="/my-list" element={<TemporaryPage title="My List" />} />
                  <Route path="/profile" element={<TemporaryPage title="Profile" />} />
                  <Route path="/login" element={<TemporaryPage title="Log in" />} />
                  <Route path="/subscribe" element={<TemporaryPage title="Subscribe" />} />
                  <Route path="/series/:seriesId" element={<TemporaryPage title="Series" />} />
                  <Route path="/series/:seriesId/episodes/:episodeId" element={<TemporaryPage title="Episode" />} />
                </Routes>
              </AppShell>
            }
          />
        </Routes>
      </ToastProvider>
    </AuthProvider>
  );
}
```

- [ ] **Step 6: Add shell CSS**

Append to `web/src/styles.css`:

```css
a {
  color: inherit;
  text-decoration: none;
}

.app-shell {
  min-height: 100vh;
  display: grid;
  grid-template-columns: 280px minmax(0, 1fr);
}

.sidebar {
  position: sticky;
  top: 0;
  height: 100vh;
  padding: 24px 18px;
  border-right: 1px solid var(--divider);
  background: rgba(11, 6, 19, 0.96);
}

.logo {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 24px;
  font-size: 28px;
  font-weight: 900;
}

.logo img {
  width: 36px;
  height: 36px;
}

.search-box {
  display: flex;
  align-items: center;
  gap: 8px;
  height: 44px;
  padding: 0 14px;
  margin-bottom: 22px;
  border: 1px solid transparent;
  border-radius: 999px;
  background: var(--surface);
  color: var(--text-muted);
}

.search-box input {
  min-width: 0;
  width: 100%;
  border: 0;
  outline: 0;
  background: transparent;
  color: var(--text);
}

.side-nav {
  display: grid;
  gap: 8px;
}

.side-nav__link {
  display: flex;
  align-items: center;
  gap: 14px;
  min-height: 48px;
  padding: 0 10px;
  border-radius: 8px;
  color: var(--text);
  font-weight: 800;
}

.side-nav__link.is-active {
  color: var(--accent);
  background: rgba(232, 121, 249, 0.1);
}

.shell-main {
  min-width: 0;
}

.top-actions {
  position: fixed;
  top: 22px;
  right: 28px;
  z-index: 20;
}

.primary-pill,
.wallet-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  min-height: 42px;
  padding: 0 18px;
  border: 0;
  border-radius: 999px;
  background: linear-gradient(135deg, var(--primary), var(--accent));
  color: white;
  font-weight: 900;
  cursor: pointer;
}

.wallet-pill {
  background: var(--surface-elevated);
  border: 1px solid var(--divider);
}

.page-surface {
  min-height: 100vh;
  padding: 96px 40px 40px;
}

.state-view {
  min-height: 320px;
  display: grid;
  place-items: center;
  align-content: center;
  gap: 14px;
  padding: 24px;
  color: var(--text-secondary);
  text-align: center;
}

.state-view h2,
.state-view p {
  margin: 0;
}

.spinner {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: 3px solid var(--divider);
  border-top-color: var(--accent);
  animation: spin 0.8s linear infinite;
}

.toast-stack {
  position: fixed;
  right: 20px;
  bottom: 20px;
  display: grid;
  gap: 10px;
  z-index: 50;
}

.toast {
  max-width: 320px;
  border: 1px solid var(--divider);
  border-radius: 8px;
  background: var(--surface-elevated);
  padding: 12px 14px;
  color: var(--text);
}

.toast--error {
  border-color: rgba(239, 68, 68, 0.5);
}

.toast--success {
  border-color: rgba(34, 197, 94, 0.5);
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

@media (max-width: 780px) {
  .app-shell {
    grid-template-columns: 1fr;
    padding-bottom: 68px;
  }

  .sidebar {
    position: fixed;
    top: auto;
    bottom: 0;
    z-index: 30;
    width: 100%;
    height: 68px;
    padding: 6px;
    border-top: 1px solid var(--divider);
    border-right: 0;
  }

  .logo,
  .search-box {
    display: none;
  }

  .side-nav {
    height: 100%;
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    gap: 2px;
  }

  .side-nav__link {
    min-height: 54px;
    justify-content: center;
    gap: 0;
    padding: 0;
  }

  .side-nav__link span {
    display: none;
  }

  .top-actions {
    top: 14px;
    right: 14px;
  }
}
```

- [ ] **Step 7: Run shell tests and build**

Run:

```bash
npm test --prefix web -- --run web/src/app/AppShell.test.tsx
npm run build --prefix web
```

Expected: tests and build pass.

- [ ] **Step 8: Commit app shell**

```bash
git add web/src/app web/src/components web/src/App.tsx web/src/styles.css
git commit -m "feat(web): add app shell and auth context"
```

---

### Task 6: Shorts Feed And Video Experience

**Files:**
- Create: `web/src/features/shorts/useShortsFeed.ts`
- Create: `web/src/features/shorts/ShortsPage.tsx`
- Create: `web/src/features/shorts/ShortsVideo.tsx`
- Create: `web/src/features/shorts/ShortsActionRail.tsx`
- Create: `web/src/features/shorts/ShortsInfoPanel.tsx`
- Create: `web/src/features/shorts/ShortsProgressBar.tsx`
- Create: `web/src/features/shorts/LockedEpisodeOverlay.tsx`
- Modify: `web/src/App.tsx`
- Modify: `web/src/styles.css`
- Test: `web/src/features/shorts/ShortsActionRail.test.tsx`

- [ ] **Step 1: Write action rail test**

Create `web/src/features/shorts/ShortsActionRail.test.tsx`:

```tsx
import { render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { describe, expect, it, vi } from "vitest";
import { ShortsActionRail } from "./ShortsActionRail";
import type { Episode, Series } from "../../domain/types";

const series: Series = {
  id: "s1",
  title: "Velvet Lies",
  description: "",
  coverUrl: "",
  category: "hot",
  isVip: false,
  episodeCount: 3,
  totalDurationSec: 90,
  createdAt: new Date(),
  popularity: 0,
  watchCount: 0,
  saveCount: 31_900,
  followerCount: 4_148,
  isPublished: true,
};

const episode: Episode = {
  id: "e1",
  seriesId: "s1",
  order: 1,
  videoUrl: "",
  thumbnailUrl: "",
  durationSec: 30,
  isVipLocked: false,
  watchCount: 0,
  likeCount: 242_600,
  shareCount: 4_148,
};

describe("ShortsActionRail", () => {
  it("renders compact social counts", () => {
    render(
      <MemoryRouter>
        <ShortsActionRail
          series={series}
          episode={episode}
          liked={false}
          saved={false}
          followed={false}
          onLike={vi.fn()}
          onSave={vi.fn()}
          onFollow={vi.fn()}
          onShare={vi.fn()}
        />
      </MemoryRouter>,
    );

    expect(screen.getByText("242.6K")).toBeInTheDocument();
    expect(screen.getByText("31.9K")).toBeInTheDocument();
  });
});
```

- [ ] **Step 2: Run action rail test to verify failure**

Run:

```bash
npm test --prefix web -- --run web/src/features/shorts/ShortsActionRail.test.tsx
```

Expected: fails because shorts components do not exist.

- [ ] **Step 3: Implement shorts feed hook**

Create `web/src/features/shorts/useShortsFeed.ts`:

```ts
import { useCallback, useEffect, useState } from "react";
import type { Episode, Series } from "../../domain/types";
import { db } from "../../firebase/firebase";
import { fetchEpisodesBySeriesId, fetchForYouSeries } from "../../repositories/catalogRepository";

export type ShortsFeedState = {
  loading: boolean;
  error: string | null;
  episodes: Episode[];
  seriesById: Record<string, Series>;
  reload: () => void;
};

export function useShortsFeed(): ShortsFeedState {
  const [version, setVersion] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [episodes, setEpisodes] = useState<Episode[]>([]);
  const [seriesById, setSeriesById] = useState<Record<string, Series>>({});

  useEffect(() => {
    let cancelled = false;
    async function load() {
      if (!db) {
        setError("Firebase web config is missing.");
        setLoading(false);
        return;
      }
      setLoading(true);
      setError(null);
      try {
        const series = await fetchForYouSeries(db, 20);
        const episodeGroups = await Promise.all(series.map((item) => fetchEpisodesBySeriesId(db, item.id)));
        if (cancelled) return;
        setSeriesById(Object.fromEntries(series.map((item) => [item.id, item])));
        setEpisodes(episodeGroups.flat().sort((a, b) => a.order - b.order));
      } catch (cause) {
        if (!cancelled) setError(cause instanceof Error ? cause.message : "Failed to load shorts.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    }
    void load();
    return () => {
      cancelled = true;
    };
  }, [version]);

  const reload = useCallback(() => setVersion((item) => item + 1), []);
  return { loading, error, episodes, seriesById, reload };
}
```

- [ ] **Step 4: Implement shorts components**

Create `web/src/features/shorts/ShortsActionRail.tsx`:

```tsx
import { Bookmark, Heart, Info, Plus, Send, UserCheck } from "lucide-react";
import { Link } from "react-router-dom";
import type { Episode, Series } from "../../domain/types";
import { compactCount } from "../../shared/format";

type Props = {
  series: Series;
  episode: Episode;
  liked: boolean;
  saved: boolean;
  followed: boolean;
  onLike: () => void;
  onSave: () => void;
  onFollow: () => void;
  onShare: () => void;
};

export function ShortsActionRail({ series, episode, liked, saved, followed, onLike, onSave, onFollow, onShare }: Props) {
  return (
    <div className="shorts-rail" aria-label="Video actions">
      <button className="rail-avatar" onClick={onFollow} aria-label={followed ? "Unfollow series" : "Follow series"}>
        {series.coverUrl ? <img src={series.coverUrl} alt="" /> : <span>{series.title.slice(0, 1)}</span>}
        <span className={`rail-avatar__badge ${followed ? "is-followed" : ""}`}>{followed ? <UserCheck size={13} /> : <Plus size={13} />}</span>
      </button>
      <RailButton active={liked} label={compactCount(episode.likeCount)} onClick={onLike} ariaLabel="Like episode">
        <Heart fill={liked ? "currentColor" : "none"} />
      </RailButton>
      <Link className="rail-button" to={`/series/${series.id}`} aria-label="Series info">
        <span className="rail-button__circle"><Info /></span>
        <span className="rail-button__label">Info</span>
      </Link>
      <RailButton active={saved} label={compactCount(series.saveCount)} onClick={onSave} ariaLabel="Save series">
        <Bookmark fill={saved ? "currentColor" : "none"} />
      </RailButton>
      <RailButton label={compactCount(episode.shareCount)} onClick={onShare} ariaLabel="Share episode">
        <Send />
      </RailButton>
    </div>
  );
}

function RailButton({
  children,
  label,
  onClick,
  active = false,
  ariaLabel,
}: {
  children: React.ReactNode;
  label: string;
  onClick: () => void;
  active?: boolean;
  ariaLabel: string;
}) {
  return (
    <button className={`rail-button ${active ? "is-active" : ""}`} onClick={onClick} aria-label={ariaLabel}>
      <span className="rail-button__circle">{children}</span>
      <span className="rail-button__label">{label}</span>
    </button>
  );
}
```

Create `web/src/features/shorts/ShortsProgressBar.tsx`:

```tsx
export function ShortsProgressBar({ progress }: { progress: number }) {
  return (
    <div className="shorts-progress" aria-hidden="true">
      <span style={{ width: `${Math.max(0, Math.min(1, progress)) * 100}%` }} />
    </div>
  );
}
```

Create `web/src/features/shorts/ShortsInfoPanel.tsx`:

```tsx
import type { Episode, Series } from "../../domain/types";

export function ShortsInfoPanel({ series, episode }: { series: Series; episode: Episode }) {
  return (
    <div className="shorts-info">
      <h1>{series.title}</h1>
      <p className="shorts-info__episode">EP.{episode.order}</p>
      {series.description ? <p className="shorts-info__description">{series.description}</p> : null}
    </div>
  );
}
```

Create `web/src/features/shorts/LockedEpisodeOverlay.tsx`:

```tsx
import { Lock } from "lucide-react";
import type { EpisodeAccess } from "../../shared/access";

export function LockedEpisodeOverlay({ access, onLogin, onSubscribe, onUnlock }: {
  access: EpisodeAccess;
  onLogin: () => void;
  onSubscribe: () => void;
  onUnlock: () => void;
}) {
  if (access.state === "open") return null;
  const label = access.state === "vip" ? "VIP episode" : access.state === "bonus" ? `${access.bonusCost} bonus to unlock` : "Sign in to unlock";
  return (
    <div className="locked-overlay">
      <Lock size={34} />
      <h2>{label}</h2>
      {access.state === "login" ? <button className="primary-pill" onClick={onLogin}>Log in</button> : null}
      {access.state === "vip" ? <button className="primary-pill" onClick={onSubscribe}>Subscribe</button> : null}
      {access.state === "bonus" ? <button className="primary-pill" onClick={onUnlock}>Unlock</button> : null}
    </div>
  );
}
```

Create `web/src/features/shorts/ShortsVideo.tsx`:

```tsx
import { useEffect, useRef, useState } from "react";
import type { Episode } from "../../domain/types";
import { ShortsProgressBar } from "./ShortsProgressBar";

export function ShortsVideo({ episode, active, locked }: { episode: Episode; active: boolean; locked: boolean }) {
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const [progress, setProgress] = useState(0);
  const [paused, setPaused] = useState(false);

  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;
    if (active && !locked) {
      void video.play().catch(() => setPaused(true));
    } else {
      video.pause();
    }
  }, [active, locked, episode.id]);

  return (
    <div className="shorts-video" onClick={() => {
      const video = videoRef.current;
      if (!video || locked) return;
      if (video.paused) {
        void video.play();
        setPaused(false);
      } else {
        video.pause();
        setPaused(true);
      }
    }}>
      <video
        ref={videoRef}
        src={episode.videoUrl}
        poster={episode.thumbnailUrl}
        playsInline
        loop
        muted
        preload={active ? "auto" : "metadata"}
        onTimeUpdate={(event) => {
          const video = event.currentTarget;
          setProgress(video.duration > 0 ? video.currentTime / video.duration : 0);
        }}
      />
      {paused && !locked ? <div className="play-badge">▶</div> : null}
      <ShortsProgressBar progress={progress} />
    </div>
  );
}
```

- [ ] **Step 5: Implement `ShortsPage`**

Create `web/src/features/shorts/ShortsPage.tsx`:

```tsx
import { useCallback, useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../app/AuthContext";
import { EmptyView } from "../../components/EmptyView";
import { ErrorView } from "../../components/ErrorView";
import { LoadingView } from "../../components/LoadingView";
import { useToast } from "../../components/Toast";
import { db, publicOrigin } from "../../firebase/firebase";
import { recordEpisodeShare, setEpisodeLiked, setSeriesFollowed, setSeriesSaved } from "../../repositories/socialRepository";
import { episodeAccess } from "../../shared/access";
import { episodeShareText } from "../../shared/share";
import { LockedEpisodeOverlay } from "./LockedEpisodeOverlay";
import { ShortsActionRail } from "./ShortsActionRail";
import { ShortsInfoPanel } from "./ShortsInfoPanel";
import { ShortsVideo } from "./ShortsVideo";
import { useShortsFeed } from "./useShortsFeed";

export function ShortsPage() {
  const feed = useShortsFeed();
  const { firebaseUser, appUser } = useAuth();
  const { showToast } = useToast();
  const navigate = useNavigate();
  const [current, setCurrent] = useState(0);

  const activeEpisode = feed.episodes[current];
  const activeSeries = activeEpisode ? feed.seriesById[activeEpisode.seriesId] : undefined;
  const liked = Boolean(activeEpisode && appUser?.likedEpisodeIds.includes(activeEpisode.id));
  const saved = Boolean(activeSeries && appUser?.favoriteSeriesIds.includes(activeSeries.id));
  const followed = Boolean(activeSeries && appUser?.followedSeriesIds.includes(activeSeries.id));
  const access = useMemo(() => activeEpisode ? episodeAccess(activeEpisode, appUser) : { state: "open" as const }, [activeEpisode, appUser]);

  useEffect(() => {
    function onKey(event: KeyboardEvent) {
      if (event.key === "ArrowDown") setCurrent((value) => Math.min(feed.episodes.length - 1, value + 1));
      if (event.key === "ArrowUp") setCurrent((value) => Math.max(0, value - 1));
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [feed.episodes.length]);

  const requireUser = useCallback(() => {
    if (firebaseUser) return firebaseUser.uid;
    navigate("/login");
    return null;
  }, [firebaseUser, navigate]);

  const runSocial = useCallback(async (action: () => Promise<void>) => {
    try {
      await action();
    } catch (error) {
      showToast(error instanceof Error ? error.message : "Action failed", "error");
    }
  }, [showToast]);

  if (feed.loading) return <LoadingView label="Loading shorts" />;
  if (feed.error) return <ErrorView message={feed.error} onRetry={feed.reload} />;
  if (!activeEpisode || !activeSeries) return <EmptyView title="No shorts yet" message="Published episodes will appear here." />;

  return (
    <section className="shorts-stage" onWheel={(event) => {
      if (Math.abs(event.deltaY) < 20) return;
      setCurrent((value) => Math.max(0, Math.min(feed.episodes.length - 1, value + (event.deltaY > 0 ? 1 : -1))));
    }}>
      <div className="shorts-card">
        <ShortsVideo episode={activeEpisode} active locked={access.state !== "open"} />
        <LockedEpisodeOverlay
          access={access}
          onLogin={() => navigate("/login")}
          onSubscribe={() => navigate("/subscribe")}
          onUnlock={() => showToast("Bonus unlock is handled from the episode detail flow.", "info")}
        />
        <ShortsInfoPanel series={activeSeries} episode={activeEpisode} />
      </div>
      <ShortsActionRail
        series={activeSeries}
        episode={activeEpisode}
        liked={liked}
        saved={saved}
        followed={followed}
        onLike={() => {
          const uid = requireUser();
          if (uid && db) void runSocial(() => setEpisodeLiked(db, uid, activeEpisode.id, !liked));
        }}
        onSave={() => {
          const uid = requireUser();
          if (uid && db) void runSocial(() => setSeriesSaved(db, uid, activeSeries.id, !saved));
        }}
        onFollow={() => {
          const uid = requireUser();
          if (uid && db) void runSocial(() => setSeriesFollowed(db, uid, activeSeries.id, !followed));
        }}
        onShare={() => {
          const text = episodeShareText({
            seriesTitle: activeSeries.title,
            episodeOrder: activeEpisode.order,
            seriesId: activeSeries.id,
            episodeId: activeEpisode.id,
            origin: publicOrigin,
          });
          void navigator.clipboard?.writeText(text);
          if (db) void runSocial(() => recordEpisodeShare(db, activeEpisode.id));
          showToast("Share link copied", "success");
        }}
      />
    </section>
  );
}
```

- [ ] **Step 6: Wire route and styles**

In `web/src/App.tsx`, import `ShortsPage` and replace the temporary `/shorts` route:

```tsx
import { ShortsPage } from "./features/shorts/ShortsPage";
```

```tsx
<Route path="/shorts" element={<ShortsPage />} />
```

Append to `web/src/styles.css`:

```css
.shorts-stage {
  min-height: 100vh;
  display: grid;
  grid-template-columns: minmax(280px, 520px) 74px;
  gap: 22px;
  align-items: center;
  justify-content: center;
  padding: 24px 120px 24px 32px;
}

.shorts-card {
  position: relative;
  width: min(430px, calc(100vw - 420px));
  min-width: 300px;
  aspect-ratio: 9 / 16;
  max-height: calc(100vh - 48px);
  border-radius: 8px;
  overflow: hidden;
  background: #050408;
  box-shadow: 0 30px 80px rgba(0, 0, 0, 0.55);
}

.shorts-video,
.shorts-video video {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
}

.shorts-video video {
  object-fit: cover;
}

.play-badge {
  position: absolute;
  inset: 0;
  display: grid;
  place-items: center;
  font-size: 72px;
  text-shadow: 0 0 30px rgba(0, 0, 0, 0.8);
}

.shorts-progress {
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  height: 4px;
  background: rgba(255, 255, 255, 0.18);
}

.shorts-progress span {
  display: block;
  height: 100%;
  background: linear-gradient(90deg, var(--primary), var(--accent));
}

.shorts-info {
  position: absolute;
  left: 18px;
  right: 18px;
  bottom: 24px;
  z-index: 4;
  text-shadow: 0 2px 14px rgba(0, 0, 0, 0.85);
}

.shorts-info h1 {
  margin: 0;
  font-size: 22px;
  line-height: 1.15;
}

.shorts-info__episode,
.shorts-info__description {
  margin: 6px 0 0;
  color: rgba(255, 255, 255, 0.78);
}

.shorts-info__description {
  display: -webkit-box;
  overflow: hidden;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.shorts-rail {
  display: grid;
  gap: 13px;
  align-content: center;
}

.rail-button,
.rail-avatar {
  display: grid;
  justify-items: center;
  gap: 5px;
  border: 0;
  background: transparent;
  color: var(--text);
  cursor: pointer;
}

.rail-button__circle,
.rail-avatar {
  width: 54px;
  height: 54px;
  border-radius: 50%;
  display: grid;
  place-items: center;
  background: var(--surface-elevated);
}

.rail-button.is-active {
  color: #ff2d55;
}

.rail-button__label {
  max-width: 68px;
  overflow: hidden;
  text-overflow: ellipsis;
  color: var(--text-secondary);
  font-size: 13px;
  font-weight: 800;
}

.rail-avatar {
  position: relative;
  padding: 0;
}

.rail-avatar img {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  object-fit: cover;
}

.rail-avatar__badge {
  position: absolute;
  bottom: -4px;
  width: 22px;
  height: 22px;
  border: 2px solid var(--bg);
  border-radius: 50%;
  display: grid;
  place-items: center;
  background: #ff2d55;
}

.rail-avatar__badge.is-followed {
  background: var(--success);
}

.locked-overlay {
  position: absolute;
  inset: 0;
  z-index: 5;
  display: grid;
  place-items: center;
  align-content: center;
  gap: 14px;
  padding: 24px;
  background: rgba(5, 4, 8, 0.72);
  text-align: center;
}

@media (max-width: 780px) {
  .shorts-stage {
    grid-template-columns: 1fr;
    padding: 0;
  }

  .shorts-card {
    width: 100vw;
    min-width: 0;
    height: calc(100vh - 68px);
    max-height: none;
    border-radius: 0;
    aspect-ratio: auto;
  }

  .shorts-rail {
    position: fixed;
    right: 10px;
    bottom: 92px;
    z-index: 12;
  }
}
```

- [ ] **Step 7: Run tests and build**

Run:

```bash
npm test --prefix web -- --run web/src/features/shorts/ShortsActionRail.test.tsx
npm run build --prefix web
```

Expected: tests and build pass.

- [ ] **Step 8: Commit shorts feed**

```bash
git add web/src/features/shorts web/src/App.tsx web/src/styles.css
git commit -m "feat(web): add shorts feed"
```

---

### Task 7: Discover, Series Detail, And Direct Player Routes

**Files:**
- Create: `web/src/features/discover/DiscoverPage.tsx`
- Create: `web/src/features/discover/SeriesCard.tsx`
- Create: `web/src/features/series/SeriesDetailPage.tsx`
- Create: `web/src/features/series/EpisodeRoutePage.tsx`
- Modify: `web/src/App.tsx`
- Modify: `web/src/styles.css`
- Test: `web/src/features/discover/SeriesCard.test.tsx`

- [ ] **Step 1: Write series card test**

Create `web/src/features/discover/SeriesCard.test.tsx`:

```tsx
import { render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { describe, expect, it } from "vitest";
import { SeriesCard } from "./SeriesCard";

describe("SeriesCard", () => {
  it("links to the series detail page", () => {
    render(
      <MemoryRouter>
        <SeriesCard
          series={{
            id: "s1",
            title: "Velvet Lies",
            description: "A secret romance.",
            coverUrl: "https://example.com/c.jpg",
            category: "hot",
            isVip: true,
            episodeCount: 8,
            totalDurationSec: 500,
            createdAt: new Date(),
            popularity: 20,
            watchCount: 0,
            saveCount: 10,
            followerCount: 4,
            isPublished: true,
          }}
        />
      </MemoryRouter>,
    );

    expect(screen.getByRole("link", { name: /velvet lies/i })).toHaveAttribute("href", "/series/s1");
    expect(screen.getByText("VIP")).toBeInTheDocument();
  });
});
```

- [ ] **Step 2: Run test to verify failure**

Run:

```bash
npm test --prefix web -- --run web/src/features/discover/SeriesCard.test.tsx
```

Expected: fails because `SeriesCard` does not exist.

- [ ] **Step 3: Implement discover components**

Create `web/src/features/discover/SeriesCard.tsx`:

```tsx
import { Link } from "react-router-dom";
import type { Series } from "../../domain/types";
import { compactCount } from "../../shared/format";

export function SeriesCard({ series }: { series: Series }) {
  return (
    <Link className="series-card" to={`/series/${series.id}`} aria-label={series.title}>
      <img src={series.coverUrl || "/branding/splash_hero.png"} alt="" />
      <div className="series-card__body">
        <h3>{series.title}</h3>
        <p>{series.episodeCount} episodes · {compactCount(series.followerCount)} followers</p>
        {series.isVip ? <span className="vip-chip">VIP</span> : null}
      </div>
    </Link>
  );
}
```

Create `web/src/features/discover/DiscoverPage.tsx`:

```tsx
import { useEffect, useState } from "react";
import type { CategoryId, Series } from "../../domain/types";
import { categories } from "../../domain/types";
import { db } from "../../firebase/firebase";
import { fetchSeriesByCategory } from "../../repositories/catalogRepository";
import { EmptyView } from "../../components/EmptyView";
import { ErrorView } from "../../components/ErrorView";
import { LoadingView } from "../../components/LoadingView";
import { SeriesCard } from "./SeriesCard";

export function DiscoverPage() {
  const [category, setCategory] = useState<CategoryId>("forYou");
  const [series, setSeries] = useState<Series[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    async function load() {
      if (!db) {
        setError("Firebase web config is missing.");
        setLoading(false);
        return;
      }
      setLoading(true);
      setError(null);
      try {
        const next = await fetchSeriesByCategory(db, category, 40);
        if (!cancelled) setSeries(next);
      } catch (cause) {
        if (!cancelled) setError(cause instanceof Error ? cause.message : "Failed to load series.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    }
    void load();
    return () => {
      cancelled = true;
    };
  }, [category]);

  return (
    <section className="catalog-page">
      <h1>Explore</h1>
      <div className="category-tabs" role="tablist">
        {categories.map((item) => (
          <button key={item.id} className={item.id === category ? "is-active" : ""} onClick={() => setCategory(item.id)}>
            {item.label}
          </button>
        ))}
      </div>
      {loading ? <LoadingView label="Loading series" /> : null}
      {error ? <ErrorView message={error} /> : null}
      {!loading && !error && series.length === 0 ? <EmptyView title="No series yet" message="Try another category." /> : null}
      <div className="series-grid">
        {series.map((item) => <SeriesCard key={item.id} series={item} />)}
      </div>
    </section>
  );
}
```

- [ ] **Step 4: Implement series routes**

Create `web/src/features/series/SeriesDetailPage.tsx`:

```tsx
import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { EmptyView } from "../../components/EmptyView";
import { ErrorView } from "../../components/ErrorView";
import { LoadingView } from "../../components/LoadingView";
import type { Episode, Series } from "../../domain/types";
import { db } from "../../firebase/firebase";
import { fetchEpisodesBySeriesId, fetchSeriesById } from "../../repositories/catalogRepository";
import { durationLabel } from "../../shared/format";

export function SeriesDetailPage() {
  const { seriesId = "" } = useParams();
  const [series, setSeries] = useState<Series | null>(null);
  const [episodes, setEpisodes] = useState<Episode[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    async function load() {
      if (!db) {
        setError("Firebase web config is missing.");
        setLoading(false);
        return;
      }
      try {
        const [nextSeries, nextEpisodes] = await Promise.all([
          fetchSeriesById(db, seriesId),
          fetchEpisodesBySeriesId(db, seriesId),
        ]);
        if (!cancelled) {
          setSeries(nextSeries);
          setEpisodes(nextEpisodes);
        }
      } catch (cause) {
        if (!cancelled) setError(cause instanceof Error ? cause.message : "Failed to load series.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    }
    void load();
    return () => {
      cancelled = true;
    };
  }, [seriesId]);

  if (loading) return <LoadingView label="Loading series" />;
  if (error) return <ErrorView message={error} />;
  if (!series) return <EmptyView title="Series not found" message="This story is not available." />;

  return (
    <section className="series-detail">
      <img className="series-detail__cover" src={series.coverUrl || "/branding/splash_hero.png"} alt="" />
      <div className="series-detail__content">
        <h1>{series.title}</h1>
        {series.isVip ? <span className="vip-chip">VIP</span> : null}
        <p>{series.description}</p>
        <div className="episode-list">
          {episodes.map((episode) => (
            <Link key={episode.id} to={`/series/${series.id}/episodes/${episode.id}`} className="episode-row">
              <span>EP.{episode.order}</span>
              <span>{durationLabel(episode.durationSec)}</span>
              {episode.isVipLocked ? <span className="vip-chip">VIP</span> : null}
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
}
```

Create `web/src/features/series/EpisodeRoutePage.tsx`:

```tsx
import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { ErrorView } from "../../components/ErrorView";
import { LoadingView } from "../../components/LoadingView";
import type { Episode, Series } from "../../domain/types";
import { db } from "../../firebase/firebase";
import { fetchEpisodeById, fetchSeriesById } from "../../repositories/catalogRepository";
import { ShortsVideo } from "../shorts/ShortsVideo";

export function EpisodeRoutePage() {
  const { seriesId = "", episodeId = "" } = useParams();
  const [series, setSeries] = useState<Series | null>(null);
  const [episode, setEpisode] = useState<Episode | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function load() {
      if (!db) {
        setError("Firebase web config is missing.");
        return;
      }
      const [nextSeries, nextEpisode] = await Promise.all([
        fetchSeriesById(db, seriesId),
        fetchEpisodeById(db, episodeId),
      ]);
      setSeries(nextSeries);
      setEpisode(nextEpisode);
    }
    void load().catch((cause) => setError(cause instanceof Error ? cause.message : "Failed to load episode."));
  }, [seriesId, episodeId]);

  if (error) return <ErrorView message={error} />;
  if (!series || !episode) return <LoadingView label="Loading episode" />;

  return (
    <section className="direct-player">
      <div className="shorts-card">
        <ShortsVideo episode={episode} active locked={false} />
      </div>
      <div className="direct-player__details">
        <h1>{series.title}</h1>
        <p>EP.{episode.order}</p>
        <Link className="primary-pill" to={`/series/${series.id}`}>View series</Link>
      </div>
    </section>
  );
}
```

- [ ] **Step 5: Wire routes and styles**

In `web/src/App.tsx`, import and route:

```tsx
import { DiscoverPage } from "./features/discover/DiscoverPage";
import { EpisodeRoutePage } from "./features/series/EpisodeRoutePage";
import { SeriesDetailPage } from "./features/series/SeriesDetailPage";
```

Replace temporary routes:

```tsx
<Route path="/discover" element={<DiscoverPage />} />
<Route path="/series/:seriesId" element={<SeriesDetailPage />} />
<Route path="/series/:seriesId/episodes/:episodeId" element={<EpisodeRoutePage />} />
```

Append CSS:

```css
.catalog-page,
.series-detail,
.direct-player {
  min-height: 100vh;
  padding: 92px 40px 40px;
}

.category-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin: 22px 0;
}

.category-tabs button {
  border: 1px solid var(--divider);
  border-radius: 999px;
  background: var(--surface);
  color: var(--text-secondary);
  padding: 10px 16px;
  cursor: pointer;
}

.category-tabs button.is-active {
  color: white;
  background: var(--primary);
}

.series-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 18px;
}

.series-card {
  overflow: hidden;
  border: 1px solid var(--divider);
  border-radius: 8px;
  background: var(--surface);
}

.series-card img {
  display: block;
  width: 100%;
  aspect-ratio: 3 / 4;
  object-fit: cover;
}

.series-card__body {
  padding: 12px;
}

.series-card h3,
.series-card p {
  margin: 0;
}

.series-card p {
  margin-top: 5px;
  color: var(--text-secondary);
  font-size: 13px;
}

.vip-chip {
  display: inline-flex;
  width: max-content;
  margin-top: 8px;
  border-radius: 999px;
  background: rgba(255, 209, 102, 0.14);
  color: var(--vip-gold);
  padding: 4px 8px;
  font-size: 12px;
  font-weight: 900;
}

.series-detail {
  display: grid;
  grid-template-columns: minmax(220px, 340px) minmax(0, 720px);
  gap: 28px;
}

.series-detail__cover {
  width: 100%;
  border-radius: 8px;
  aspect-ratio: 3 / 4;
  object-fit: cover;
}

.episode-list {
  display: grid;
  gap: 10px;
  margin-top: 24px;
}

.episode-row {
  display: grid;
  grid-template-columns: 1fr auto auto;
  gap: 12px;
  align-items: center;
  border: 1px solid var(--divider);
  border-radius: 8px;
  background: var(--surface);
  padding: 14px;
}

.direct-player {
  display: grid;
  grid-template-columns: minmax(300px, 430px) minmax(240px, 420px);
  gap: 30px;
  align-items: center;
  justify-content: center;
}

.direct-player .shorts-card {
  width: 100%;
}

@media (max-width: 780px) {
  .catalog-page,
  .series-detail,
  .direct-player {
    padding: 76px 16px 92px;
  }

  .series-detail,
  .direct-player {
    grid-template-columns: 1fr;
  }
}
```

- [ ] **Step 6: Run tests and build**

Run:

```bash
npm test --prefix web -- --run web/src/features/discover/SeriesCard.test.tsx
npm run build --prefix web
```

Expected: tests and build pass.

- [ ] **Step 7: Commit catalog routes**

```bash
git add web/src/features/discover web/src/features/series web/src/App.tsx web/src/styles.css
git commit -m "feat(web): add catalog and series routes"
```

---

### Task 8: Auth, Profile, Rewards, My List, And Following Screens

**Files:**
- Create: `web/src/features/auth/LoginPage.tsx`
- Create: `web/src/features/profile/ProfilePage.tsx`
- Create: `web/src/features/rewards/RewardsPage.tsx`
- Create: `web/src/features/my-list/MyListPage.tsx`
- Create: `web/src/features/my-list/FollowingPage.tsx`
- Create: `web/src/features/subscription/SubscribePage.tsx`
- Modify: `web/src/App.tsx`
- Modify: `web/src/styles.css`
- Test: `web/src/features/auth/LoginPage.test.tsx`

- [ ] **Step 1: Write login page smoke test**

Create `web/src/features/auth/LoginPage.test.tsx`:

```tsx
import { render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { describe, expect, it } from "vitest";
import { ToastProvider } from "../../components/Toast";
import { LoginPage } from "./LoginPage";

describe("LoginPage", () => {
  it("renders email and Google auth actions", () => {
    render(
      <MemoryRouter>
        <ToastProvider>
          <LoginPage />
        </ToastProvider>
      </MemoryRouter>,
    );

    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /continue/i })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /google/i })).toBeInTheDocument();
  });
});
```

- [ ] **Step 2: Run test to verify failure**

Run:

```bash
npm test --prefix web -- --run web/src/features/auth/LoginPage.test.tsx
```

Expected: fails because `LoginPage` does not exist.

- [ ] **Step 3: Implement auth screen**

Create `web/src/features/auth/LoginPage.tsx`:

```tsx
import { useState } from "react";
import { GoogleAuthProvider, createUserWithEmailAndPassword, signInWithEmailAndPassword, signInWithPopup } from "firebase/auth";
import { useNavigate } from "react-router-dom";
import { useToast } from "../../components/Toast";
import { auth } from "../../firebase/firebase";

export function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [mode, setMode] = useState<"login" | "signup">("login");
  const { showToast } = useToast();
  const navigate = useNavigate();

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    if (!auth) {
      showToast("Firebase web config is missing.", "error");
      return;
    }
    try {
      if (mode === "login") {
        await signInWithEmailAndPassword(auth, email, password);
      } else {
        await createUserWithEmailAndPassword(auth, email, password);
      }
      navigate("/shorts");
    } catch (error) {
      showToast(error instanceof Error ? error.message : "Sign in failed", "error");
    }
  }

  async function google() {
    if (!auth) {
      showToast("Firebase web config is missing.", "error");
      return;
    }
    try {
      await signInWithPopup(auth, new GoogleAuthProvider());
      navigate("/shorts");
    } catch (error) {
      showToast(error instanceof Error ? error.message : "Google sign in failed", "error");
    }
  }

  return (
    <section className="auth-page">
      <form className="auth-card" onSubmit={submit}>
        <h1>{mode === "login" ? "Log in" : "Create account"}</h1>
        <label>
          Email
          <input value={email} onChange={(event) => setEmail(event.target.value)} type="email" required />
        </label>
        <label>
          Password
          <input value={password} onChange={(event) => setPassword(event.target.value)} type="password" required minLength={6} />
        </label>
        <button className="primary-pill" type="submit">Continue</button>
        <button className="wallet-pill" type="button" onClick={google}>Continue with Google</button>
        <button className="text-button" type="button" onClick={() => setMode(mode === "login" ? "signup" : "login")}>
          {mode === "login" ? "Create an account" : "I already have an account"}
        </button>
      </form>
    </section>
  );
}
```

- [ ] **Step 4: Implement profile/rewards/list/subscription screens**

Create `web/src/features/profile/ProfilePage.tsx`:

```tsx
import { signOut } from "firebase/auth";
import { Link } from "react-router-dom";
import { useAuth } from "../../app/AuthContext";
import { auth } from "../../firebase/firebase";

export function ProfilePage() {
  const { appUser, firebaseUser } = useAuth();
  if (!firebaseUser) {
    return <section className="page-surface"><h1>Profile</h1><Link className="primary-pill" to="/login">Log in</Link></section>;
  }
  return (
    <section className="page-surface profile-grid">
      <div>
        <h1>{appUser?.displayName || firebaseUser.email || "ShortiGo user"}</h1>
        <p>{appUser?.isVip ? "VIP active" : "Free account"}</p>
        <button className="wallet-pill" onClick={() => auth && signOut(auth)}>Sign out</button>
      </div>
      <div className="wallet-card"><span>Coins</span><strong>{appUser?.coins ?? 0}</strong></div>
      <div className="wallet-card"><span>Bonus</span><strong>{appUser?.bonus ?? 0}</strong></div>
    </section>
  );
}
```

Create `web/src/features/rewards/RewardsPage.tsx`:

```tsx
import { useAuth } from "../../app/AuthContext";
import { useToast } from "../../components/Toast";
import { auth, db, rewardApiBaseUrl } from "../../firebase/firebase";
import { claimDailyCheckIn, grantWebAdReward } from "../../repositories/rewardsRepository";

export function RewardsPage() {
  const { firebaseUser, appUser } = useAuth();
  const { showToast } = useToast();

  async function daily() {
    if (!firebaseUser || !auth || !db) {
      showToast("Log in to claim rewards.", "error");
      return;
    }
    await claimDailyCheckIn({ db, auth, userId: firebaseUser.uid, rewardApiBaseUrl });
    showToast("Daily bonus claimed", "success");
  }

  async function webReward() {
    if (!firebaseUser || !db) {
      showToast("Log in to claim rewards.", "error");
      return;
    }
    await grantWebAdReward(db, firebaseUser.uid);
    showToast("Web reward added", "success");
  }

  return (
    <section className="page-surface rewards-grid">
      <h1>Rewards</h1>
      <div className="reward-card">
        <h2>Daily check-in</h2>
        <p>Current bonus: {appUser?.bonus ?? 0}</p>
        <button className="primary-pill" onClick={() => void daily()}>Claim daily bonus</button>
      </div>
      <div className="reward-card">
        <h2>Web reward</h2>
        <p>Use this web-safe reward until a browser ad provider is configured.</p>
        <button className="wallet-pill" onClick={() => void webReward()}>Claim web reward</button>
      </div>
    </section>
  );
}
```

Create `web/src/features/my-list/MyListPage.tsx`:

```tsx
import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { useAuth } from "../../app/AuthContext";
import { EmptyView } from "../../components/EmptyView";
import { ErrorView } from "../../components/ErrorView";
import { LoadingView } from "../../components/LoadingView";
import type { Series } from "../../domain/types";
import { db } from "../../firebase/firebase";
import { fetchSeriesByIds } from "../../repositories/catalogRepository";
import { SeriesCard } from "../discover/SeriesCard";

export function MyListPage() {
  const { appUser, loading: authLoading } = useAuth();
  const [series, setSeries] = useState<Series[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    async function load() {
      if (authLoading) return;
      if (!appUser) {
        setSeries([]);
        return;
      }
      if (!db) {
        setError("Firebase web config is missing.");
        return;
      }
      setLoading(true);
      setError(null);
      try {
        const next = await fetchSeriesByIds(db, appUser.favoriteSeriesIds);
        if (!cancelled) setSeries(next);
      } catch (cause) {
        if (!cancelled) setError(cause instanceof Error ? cause.message : "Failed to load saved series.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    }
    void load();
    return () => {
      cancelled = true;
    };
  }, [appUser, authLoading]);

  if (authLoading || loading) return <LoadingView label="Loading saved series" />;
  if (!appUser) return <EmptyView title="Log in to view My List" message="Saved series are linked to your ShortiGo account." />;
  if (error) return <ErrorView message={error} />;
  if (series.length === 0) return <EmptyView title="My List is empty" message="Save a series from the Shorts feed or Explore." />;

  return (
    <section className="catalog-page">
      <h1>My List</h1>
      <div className="series-grid">
        {series.map((item) => <SeriesCard key={item.id} series={item} />)}
      </div>
      <Link className="text-button" to="/discover">Explore more series</Link>
    </section>
  );
}
```

Create `web/src/features/my-list/FollowingPage.tsx`:

```tsx
import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { useAuth } from "../../app/AuthContext";
import { EmptyView } from "../../components/EmptyView";
import { ErrorView } from "../../components/ErrorView";
import { LoadingView } from "../../components/LoadingView";
import type { Series } from "../../domain/types";
import { db } from "../../firebase/firebase";
import { fetchSeriesByIds } from "../../repositories/catalogRepository";
import { SeriesCard } from "../discover/SeriesCard";

export function FollowingPage() {
  const { appUser, loading: authLoading } = useAuth();
  const [series, setSeries] = useState<Series[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    async function load() {
      if (authLoading) return;
      if (!appUser) {
        setSeries([]);
        return;
      }
      if (!db) {
        setError("Firebase web config is missing.");
        return;
      }
      setLoading(true);
      setError(null);
      try {
        const next = await fetchSeriesByIds(db, appUser.followedSeriesIds);
        if (!cancelled) setSeries(next);
      } catch (cause) {
        if (!cancelled) setError(cause instanceof Error ? cause.message : "Failed to load followed series.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    }
    void load();
    return () => {
      cancelled = true;
    };
  }, [appUser, authLoading]);

  if (authLoading || loading) return <LoadingView label="Loading followed series" />;
  if (!appUser) return <EmptyView title="Log in to view Following" message="Followed series are linked to your ShortiGo account." />;
  if (error) return <ErrorView message={error} />;
  if (series.length === 0) return <EmptyView title="No followed series yet" message="Follow series from the Shorts feed." />;

  return (
    <section className="catalog-page">
      <h1>Following</h1>
      <div className="series-grid">
        {series.map((item) => <SeriesCard key={item.id} series={item} />)}
      </div>
      <Link className="text-button" to="/shorts">Watch For You</Link>
    </section>
  );
}
```

Create `web/src/features/subscription/SubscribePage.tsx`:

```tsx
export function SubscribePage() {
  return (
    <section className="page-surface subscribe-page">
      <h1>ShortiGo VIP</h1>
      <p>Unlock VIP episodes and keep watching without waiting. Web payment integration is handled in a dedicated billing milestone.</p>
      <button className="primary-pill" disabled>Web billing not configured</button>
    </section>
  );
}
```

- [ ] **Step 5: Wire routes**

In `web/src/App.tsx`, import:

```tsx
import { LoginPage } from "./features/auth/LoginPage";
import { FollowingPage } from "./features/my-list/FollowingPage";
import { MyListPage } from "./features/my-list/MyListPage";
import { ProfilePage } from "./features/profile/ProfilePage";
import { RewardsPage } from "./features/rewards/RewardsPage";
import { SubscribePage } from "./features/subscription/SubscribePage";
```

Replace temporary routes:

```tsx
<Route path="/following" element={<FollowingPage />} />
<Route path="/rewards" element={<RewardsPage />} />
<Route path="/my-list" element={<MyListPage />} />
<Route path="/profile" element={<ProfilePage />} />
<Route path="/login" element={<LoginPage />} />
<Route path="/subscribe" element={<SubscribePage />} />
```

- [ ] **Step 6: Add screen CSS**

Append:

```css
.auth-page {
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: 80px 20px;
}

.auth-card {
  width: min(420px, 100%);
  display: grid;
  gap: 16px;
  border: 1px solid var(--divider);
  border-radius: 8px;
  background: var(--surface);
  padding: 24px;
}

.auth-card label {
  display: grid;
  gap: 7px;
  color: var(--text-secondary);
  font-weight: 700;
}

.auth-card input {
  height: 44px;
  border: 1px solid var(--divider);
  border-radius: 8px;
  background: var(--bg);
  color: var(--text);
  padding: 0 12px;
}

.text-button {
  border: 0;
  background: transparent;
  color: var(--accent);
  cursor: pointer;
  font-weight: 800;
}

.profile-grid,
.rewards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 16px;
}

.profile-grid h1,
.rewards-grid h1 {
  grid-column: 1 / -1;
}

.wallet-card,
.reward-card {
  border: 1px solid var(--divider);
  border-radius: 8px;
  background: var(--surface);
  padding: 20px;
}

.wallet-card {
  display: grid;
  gap: 8px;
}

.wallet-card strong {
  font-size: 34px;
}
```

- [ ] **Step 7: Run tests and build**

Run:

```bash
npm test --prefix web -- --run web/src/features/auth/LoginPage.test.tsx
npm run build --prefix web
```

Expected: tests and build pass.

- [ ] **Step 8: Commit account screens**

```bash
git add web/src/features/auth web/src/features/profile web/src/features/rewards web/src/features/my-list web/src/features/subscription web/src/App.tsx web/src/styles.css
git commit -m "feat(web): add auth profile and rewards screens"
```

---

### Task 9: Hosting, Docs, And Final Verification

**Files:**
- Modify: `firebase.json`
- Modify: `README.md`

- [ ] **Step 1: Build the web app**

Run:

```bash
npm run build --prefix web
```

Expected: `web/dist` is created and build exits 0.

- [ ] **Step 2: Decide hosting target without replacing legal pages**

If the app should deploy to the main ShortiGo hosting site, modify `firebase.json` to use rewrites while preserving static legal pages:

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "hosting": [
    {
      "target": "public-web",
      "public": "web/dist",
      "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
      "cleanUrls": true,
      "trailingSlash": false,
      "rewrites": [{ "source": "**", "destination": "/index.html" }]
    },
    {
      "target": "static-pages",
      "public": "hosting/public",
      "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
      "cleanUrls": true,
      "trailingSlash": false
    }
  ]
}
```

If Firebase targets are not configured yet, leave `firebase.json` unchanged and document the deployment command in `README.md` instead. Do not replace `hosting/public` silently.

- [ ] **Step 3: Add README web instructions**

Append to `README.md`:

```md
## Web app

The public consumer web app lives in `web/`.

```bash
cp web/.env.example web/.env.local
npm install --prefix web
npm run dev --prefix web
npm run build --prefix web
npm test --prefix web
```

Required Firebase variables use the same `VITE_FIREBASE_*` pattern as the admin app.
The web app reads the existing ShortiGo Firestore collections: `series`, `episodes`,
`users`, `transactions`, and `admin/featured`.
```

- [ ] **Step 4: Run full verification**

Run:

```bash
npm test --prefix web
npm run build --prefix web
```

Expected: tests and production build pass.

- [ ] **Step 5: Browser verification**

Run:

```bash
npm run dev --prefix web -- --host 127.0.0.1
```

Open the printed localhost URL in the in-app browser. Verify:

- `/shorts` renders the TikTok-like center-stage layout.
- Desktop width has left sidebar, centered vertical player, and right action rail without overlap.
- Narrow width collapses navigation to the bottom and keeps video/action controls usable.
- Missing Firebase env shows an understandable error state rather than a blank app.
- `/discover`, `/series/example`, `/login`, `/profile`, `/rewards`, `/my-list`, `/following`, and `/subscribe` render without crashing.

Stop the dev server after verification.

- [ ] **Step 6: Optional React Doctor**

Run:

```bash
npx -y react-doctor@latest web --verbose --diff
```

Expected: no high-severity issues. Fix high-severity diagnostics before finishing.

- [ ] **Step 7: Commit deployment/docs**

```bash
git add firebase.json README.md
git commit -m "docs(web): add deployment instructions"
```

If `firebase.json` was unchanged, run:

```bash
git add README.md
git commit -m "docs(web): add development instructions"
```

---

## Self-Review Notes

- Spec coverage: The plan covers a separate React/Vite app under `web/`, Firebase Auth/Firestore, TikTok-like shorts layout, discover, series detail, direct episode route, profile/wallet, rewards, My List/Following hydrated from user series IDs, subscription CTA, error states, tests, build, browser verification, and hosting documentation.
- Known first-build limitation: Web payments remain intentionally disabled until a billing provider is selected.
- Web payments remain out of scope as specified. The subscribe page is a CTA/status page until a billing provider is chosen.
