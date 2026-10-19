# PanVi

PanVi is a pantry tracker built to cut household food waste. It keeps track of what's in your kitchen and when it expires, flags food that's about to go bad, and ties your pantry to a shopping list and recipes.

## What's in here

| Part | Stack | What it does |
|---|---|---|
| Mobile/web app (`lib/`) | Flutter, Dart, Provider | Pantry with expiration tracking and freshness bars, shopping list, recipes and cookbook, camera capture, user profile |
| Auth | Firebase Auth | Email, phone (SMS code), Google and Apple sign-in |
| Data | Cloud Firestore, Firebase Storage | Per-user inventory and food photos, locked down by security rules in `backend/services/*.js` |
| API (`backend/`) | Python, Flask | Authenticated endpoint for adding food items with photos; verifies Firebase ID tokens |
| Experiments (`backend/ml`, `backend/integrations`) | YOLOv8, Google Cloud Vision, Veryfi | Prototype food detection from photos and receipt scanning |

## Running it

**App**

1. Install Flutter (Dart SDK >= 3.4).
2. Create your own Firebase project and run `flutterfire configure`. This generates `lib/firebase_options.dart`, `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`. All three are git-ignored. `lib/firebase_options.example.dart` shows the shape.
3. For Google or Facebook sign-in on iOS, replace the `YOUR_...` placeholders in `ios/Runner/Info.plist`.
4. Run `flutter pub get`, then `flutter run`.

**Backend**

```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env          # fill in your own values
mkdir secrets                 # put your Firebase service-account JSON here
python app.py
```

No keys, service accounts or personal data are stored in this repo. Everything sensitive comes from `backend/.env` and `backend/secrets/`, which are git-ignored.

## Status

PanVi is in active development (v2.0.14). Food detection and receipt OCR are prototypes and aren't wired into the app yet.
