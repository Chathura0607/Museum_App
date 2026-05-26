# Museum App 🏛️

A modern, AI-powered museum companion app built with Flutter. This app enhances the museum visitor experience by providing interactive artifact details, 3D model visualization, AR capabilities, and multi-language support.

## 🚀 Features

-   **🔍 Smart QR Scanner**: Instantly access artifact information by scanning QR codes.
-   **🤖 AI Artifact Insights**: Leverages Google Generative AI to provide deep context and answers about museum exhibits.
-   **🎥 Multimedia Content**: Support for images, videos, and audio guides for each artifact.
-   **📦 3D Model Viewer**: View artifacts in 3D using `model_viewer_plus` for an immersive experience.
-   **🗣️ Text-to-Speech (TTS)**: Integrated audio guides for accessibility and hands-free learning.
-   **🌐 Multi-language Support**: Full support for English and Sinhala (localized using `intl`).
-   **🔥 Firebase Integration**: Secure authentication and real-time data sync with Cloud Firestore.
-   **💬 Feedback System**: Dedicated screen for visitors to share their experience.

## 🛠️ Technology Stack

-   **Frontend**: Flutter (Dart)
-   **Navigation**: GoRouter
-   **Backend**: Firebase (Auth, Firestore, App Check)
-   **AI**: Google Generative AI (Gemini)
-   **Scanning**: Mobile Scanner
-   **3D Rendering**: Model Viewer Plus

## 📦 Installation & Setup

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-username/museum_app.git
    cd museum_app
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**:
    -   Create a new project on the [Firebase Console](https://console.firebase.google.com/).
    -   Add Android/iOS apps to your project.
    -   Download and place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the respective directories.
    -   Alternatively, use FlutterFire CLI: `flutterfire configure`.

4.  **API Keys**:
    -   Ensure your Google Generative AI API key is configured in the project (usually in `lib/config.dart` or via environment variables).

5.  **Run the app**:
    ```bash
    flutter run
    ```

## 📸 Screenshots

*(Add screenshots here)*

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
