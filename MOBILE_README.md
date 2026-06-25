# Brainery Mobile

Flutter student app for the Brainery Spring Boot REST backend.

## Project structure

- `lib/core`: config, constants, Dio API client, token storage, routing, theme, reusable widgets.
- `lib/features/auth`: login, register, logout, current user state.
- `lib/features/home`: student home screen with categories, featured courses, popular courses.
- `lib/features/courses`: course API, models, course list, search/filter, course detail.
- `lib/features/learning`, `wishlist`, `cart`, `profile`: stage placeholders wired into bottom navigation.

## Run

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

For a real phone on the same LAN, replace `10.0.2.2` with your computer LAN IP:

```bash
flutter run --dart-define=API_BASE_URL=http://<LAN_IP>:8080
```

Production can use:

```bash
flutter run --dart-define=API_BASE_URL=https://api.brainery.com
```

## Implemented in stage 1

- App architecture split out of `main.dart`.
- Material theme and shared loading, error, empty, button, text field, and course card widgets.
- `go_router` routes and bottom navigation.
- Dio `ApiClient` with `Authorization` header, secure token storage, refresh-token retry, and HTTP error mapping.
- Auth screens: splash, login, register, logout, `/api/me`.
- Home screen with search entry, categories, featured courses, popular courses.
- Course list with keyword/category/level/free filters, pull to refresh, load more.
- Course detail with image, title, description, price, tags, sections, lessons, and stage placeholders for enroll/cart/wishlist.

## Connected endpoints

- `POST /api/auth/login`
- `POST /api/auth/register`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`
- `GET /api/me`
- `GET /api/courses`
- `GET /api/courses/{courseId}`
- `GET /api/courses/featured`
- `GET /api/categories`

## Pending next stages

- Stage 2: my learning, enrollment, lesson player, progress tracking, wishlist.
- Stage 3: cart, checkout, order, payment demo.
- Stage 4: review, comment, quiz, notification, device, downloaded lesson metadata.

Backend endpoints that are not connected yet are intentionally left as user-friendly placeholders so the app does not crash while stage 1 is being used.
