# Quizora

A comprehensive Flutter-based mobile application for online quiz management and assessment. Quizora enables educators to create and conduct quizzes while allowing students to take exams, track their progress, and compete on leaderboards.

## Features

### Student Features
- User authentication with Firebase
- Take quizzes and exams with timed questions
- View detailed exam results and performance analytics
- Track quiz history and past attempts
- Compete on leaderboards with other students
- Receive push notifications for quiz invitations
- View personal profile and quiz statistics
- Customize app settings and preferences

### Teacher Features
- Create and manage quizzes with customizable questions
- Conduct live exams and monitor student progress
- View comprehensive quiz analytics and performance metrics
- Access leaderboards to track student rankings
- Export quiz results and reports
- Manage student submissions and grades
- Real-time notifications and updates

### General Features
- Offline support for quiz content
- Cloud synchronization with Firebase
- Push notifications for important events
- Secure user authentication
- Responsive UI design
- Dark mode support
- Multi-platform support (Android, iOS, Web)

## Technical Stack

- **Frontend Framework**: Flutter (Dart)
- **Backend & Database**: Firebase (Authentication, Cloud Firestore, Storage)
- **State Management**: Provider
- **Local Storage**: Hive/Shared Preferences
- **Notifications**: Firebase Cloud Messaging, Flutter Local Notifications
- **Analytics**: Firebase Analytics
- **Charting**: FL Chart
- **File Management**: File Picker, Image Picker
- **Build System**: Gradle (Android), Xcode (iOS)

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio or VS Code
- Firebase CLI
- Android NDK (for Android development)
- Xcode (for iOS development)

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/VandanKambodi/Quizora.git
cd Quizora
```

2. **Install Flutter dependencies:**
```bash
flutter pub get
```

3. **Configure Firebase:**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add Android app to your Firebase project
     - Download `google-services.json` and place it in `android/app/`
   - Add iOS app to your Firebase project
     - Download `GoogleService-Info.plist`
   - Enable the following Firebase services:
     - Authentication (Email/Password)
     - Cloud Firestore
     - Cloud Storage
     - Cloud Messaging
     - Analytics

4. **Update Firebase configuration:**
```bash
flutterfire configure
```

5. **Build and run the app:**
```bash
flutter run
```

For iOS, you may need to run:
```bash
cd ios
pod install
cd ..
flutter run
```

## Project Structure

```
lib/
├── models/
│   ├── user_model.dart
│   ├── quiz_model.dart
│   ├── question_model.dart
│   ├── result_model.dart
│   └── ...
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── registration_screen.dart
│   ├── intro_slider.dart
│   ├── student_dashboard.dart
│   ├── exam_screen.dart
│   ├── result_screen.dart
│   ├── history_page.dart
│   ├── profile_page.dart
│   ├── settings_page.dart
│   ├── student_main_wrapper.dart
│   └── teacher/
│       ├── dashboard.dart
│       ├── add_quiz.dart
│       ├── quiz_analytics_screen.dart
│       ├── quiz_leaderboard.dart
│       ├── all_results_page.dart
│       └── teacher_main_wrapper.dart
├── services/
│   ├── database_service.dart
│   ├── authentication_service.dart
│   ├── notification_service.dart
│   ├── profile_service.dart
│   ├── quiz_service.dart
│   └── analytics_service.dart
├── theme/
│   └── app_theme.dart
├── constants.dart
├── firebase_options.dart
└── main.dart

android/
├── app/
├── gradle/
└── build.gradle.kts

ios/
├── Runner/
├── Runner.xcodeproj/
└── Runner.xcworkspace/

web/
├── index.html
├── manifest.json
└── icons/
```

## Features in Development

- Advanced quiz difficulty levels
- Custom quiz categories and tags
- Student groups and classroom management
- Detailed performance analytics dashboard
- Certificate generation for quiz completion
- Video integration in quiz questions
- Collaborative quizzes and team competitions
- Accessibility improvements (Dark mode, Text scaling)
- Multi-language support
- Social sharing of quiz results
- AI-powered quiz suggestions
- Integration with educational platforms

## Build & Deployment

### Android Build
```bash
flutter build apk
# or for App Bundle
flutter build appbundle
```

### iOS Build
```bash
flutter build ios
```

### Web Build
```bash
flutter build web
```

## Troubleshooting

### Common Issues

**Firebase Connection Issues:**
- Ensure `google-services.json` is correctly placed in `android/app/`
- Verify Firebase project ID in `.firebaserc`
- Check Firebase authentication methods are enabled

**Build Issues:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

**Android Build Failures:**
- Update Android SDK to latest version
- Check Gradle version compatibility
- Ensure Java version is compatible (Java 11 or later)

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch:
```bash
git checkout -b feature/amazing-feature
```
3. Commit your changes:
```bash
git commit -m 'Add some amazing feature'
```
4. Push to the branch:
```bash
git push origin feature/amazing-feature
```
5. Open a Pull Request

Please ensure your code follows the Flutter style guide and include appropriate documentation.

## Code Style

This project follows the [Dart Code Style Guide](https://dart.dev/guides/language/effective-dart/style) and uses:
- `dart format` for code formatting
- `dart analyze` for static analysis
- Meaningful variable and function names
- Comprehensive documentation comments

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact & Support

For support, email your-email@example.com or open an issue on GitHub.

## Acknowledgments

- Flutter community for the excellent documentation
- Firebase for backend services
- All contributors and testers

---

**Note:** This README will be updated as the project evolves. For the latest updates, please check the repository regularly.
