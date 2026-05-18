# Stela

Stela is a feature-rich mobile application built with Flutter that provides an immersive story reading experience. It combines traditional reading with an integrated text-to-speech engine, allowing users to listen to stories with synchronized text scrolling. Stela also includes comprehensive user statistics tracking and gamification elements to keep readers engaged.

## 🚀 Key Features

*   **Immersive Story Reading**: Enjoy a clean, distraction-free environment for reading stories.
*   **Integrated Text-to-Speech (TTS)**: Listen to stories on the go. Switch between male and female voices seamlessly without interrupting playback.
*   **Synchronized Audio & Text**: Lyric-style text scrolling that stays in perfect sync with the audio playback position, even when seeking.
*   **User Statistics Tracking**: Monitor your reading habits with detailed stats, including reading streaks, total stories read, and cumulative read time.
*   **Gamification & Badges**: Earn badges based on your reading milestones (e.g., meeting reading thresholds).
*   **Modern & Responsive UI**: Navigate easily with a sleek, pill-shaped bottom navigation bar (Home, Library, Profile) and responsive layouts.
*   **Secure Authentication**: Seamless account registration and login powered by Firebase Authentication.

## 🛠️ Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/) (Dart)
*   **State Management**: Provider
*   **Dependency Injection**: GetIt & Injectable
*   **Backend & Database**: Firebase (Authentication, Cloud Firestore)
*   **Networking**: Dio & Retrofit
*   **Audio & TTS**: `just_audio` and `flutter_tts`
*   **UI/UX**: `fl_chart` (Data Visualization), `flutter_animate`, `fast_cached_network_image`

## 📦 Getting Started

### Prerequisites

*   Flutter SDK (^3.10.1)
*   Dart SDK
*   A Firebase Project (for Auth and Firestore)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/quabiee07/stela-mobile.git
    cd stela-mobile
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Code Generation (Optional):**
    If you make changes to models or injection configurations, run the build runner:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Setup Environment Variables:**
    Create a `.env` file in the `assets/env/` directory to store your API keys and configuration values.

5.  **Firebase Setup:**
    Ensure you have configured Firebase for iOS and/or Android. You may need to run `flutterfire configure` to generate the `firebase_options.dart` file.

6.  **Run the app:**
    ```bash
    flutter run
    ```

## 🏗️ Architecture

The app follows **Clean Architecture** principles, ensuring a robust separation of concerns across presentation, domain, and data layers. This structure promotes modular development, straightforward testing, and scalable feature integration.
