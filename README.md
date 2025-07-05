# Notes Taking App

A modern, feature-rich notes taking application built with Flutter and Firebase. This app provides a seamless experience for creating, organizing, and managing personal notes with real-time synchronization across devices.

## 🚀 Features

- **User Authentication**: Secure login and registration with Firebase Auth
- **Real-time Sync**: Notes are synchronized across devices using Cloud Firestore
- **Note Management**: Create, edit, delete, and organize notes
- **Categories & Tags**: Organize notes with customizable categories and tags
- **Search Functionality**: Powerful search across note titles, content, and tags
- **Pin Notes**: Pin important notes to keep them at the top
- **Responsive UI**: Beautiful, modern interface that works across all platforms
- **Offline Support**: Continue working even without internet connection

## 📱 Screenshots

*Coming soon - Screenshots will be added after UI implementation*

## 🏗️ Architecture

The app follows a clean architecture pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                          UI Layer                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │ Login Screen│ │Notes Screen │ │ Add/Edit Note Screen    │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Controller Layer                        │
│  ┌─────────────────┐           ┌─────────────────────────┐   │
│  │  AuthController │           │    NotesController      │   │
│  │  - login()      │           │    - fetchNotes()       │   │
│  │  - register()   │           │    - addNote()          │   │
│  │  - logout()     │           │    - updateNote()       │   │
│  └─────────────────┘           │    - deleteNote()       │   │
│                                │    - searchNotes()      │   │
│                                └─────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       Model Layer                           │
│  ┌─────────────────┐           ┌─────────────────────────┐   │
│  │   User Model    │           │      Note Model        │   │
│  │  - id           │           │    - id                 │   │
│  │  - email        │           │    - title              │   │
│  │  - firstName    │           │    - content            │   │
│  │  - lastName     │           │    - category           │   │
│  └─────────────────┘           │    - tags               │   │
│                                │    - isPinned           │   │
│                                │    - createdAt          │   │
│                                │    - updatedAt          │   │
│                                └─────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Firebase Services                       │
│  ┌─────────────────┐           ┌─────────────────────────┐   │
│  │ Firebase Auth   │           │   Cloud Firestore      │   │
│  │ - Authentication│           │   - Notes Storage       │   │
│  │ - User Management│          │   - Real-time Updates  │   │
│  └─────────────────┘           └─────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Key Architectural Decisions

1. **GetX State Management**: Chosen for its simplicity and powerful reactive programming capabilities
2. **Firebase Integration**: Provides robust backend services with minimal setup
3. **Model-View-Controller (MVC)**: Clear separation between data, business logic, and UI
4. **Repository Pattern**: Future-ready architecture for data source abstraction

## 🛠️ Technology Stack

- **Frontend**: Flutter 3.32.0
- **State Management**: GetX 4.6.6
- **Backend**: Firebase
  - Authentication: Firebase Auth 5.3.4
  - Database: Cloud Firestore 5.6.11
  - Core: Firebase Core 3.9.0
- **Local Storage**: GetStorage 2.1.1
- **Development Tools**: 
  - Flutter Lints 5.0.0
  - Logger 2.0.2+1

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.8.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)
- A Firebase project (see setup instructions below)

## 🔧 Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/notes_taking_app.git
cd notes_taking_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

1. **Create a Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project" and follow the setup wizard

2. **Enable Authentication**:
   - In Firebase Console, go to Authentication → Sign-in method
   - Enable "Email/Password" provider

3. **Create Firestore Database**:
   - Go to Firestore Database
   - Click "Create database"
   - Choose "Start in test mode" for development

4. **Add Firebase to Your App**:
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your Flutter app
   flutterfire configure
   ```

5. **Update Firestore Security Rules**:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /notes/{noteId} {
         allow read, write: if request.auth != null && 
           request.auth.uid == resource.data.userId;
       }
       match /users/{userId} {
         allow read, write: if request.auth != null && 
           request.auth.uid == userId;
       }
     }
   }
   ```

### 4. Environment Configuration

Ensure your `firebase_options.dart` file is properly configured (generated by FlutterFire CLI).

### 5. Run the App

```bash
# For development
flutter run

# For specific platform
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS (macOS only)
```

## 🏗️ Build Instructions

### Development Build

```bash
# Debug build
flutter build apk --debug
flutter build web --debug

# With specific flavor
flutter run --flavor development
```

### Production Build

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release

# Web
flutter build web --release

# Desktop
flutter build linux --release
flutter build windows --release
flutter build macos --release
```

### Build Optimization

```bash
# Analyze app size
flutter build apk --analyze-size
flutter build appbundle --analyze-size

# Enable obfuscation (for production)
flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart

# Widget tests
flutter test test/widget_test.dart
```

## 📊 Code Quality

### Static Analysis

```bash
# Run Dart analyzer
flutter analyze

# Fix auto-fixable issues
dart fix --apply

# Format code
dart format .
```

### Performance Analysis

```bash
# Profile app performance
flutter run --profile

# Analyze app performance
flutter run --trace-startup --profile
```

## 📱 Platform Support

| Platform | Support | Status |
|----------|---------|---------|
| Android  | ✅ | Full support (API 21+) |
| iOS      | ✅ | Full support (iOS 12+) |
| Web      | ✅ | Progressive Web App |
| Windows  | ✅ | Desktop application |
| macOS    | ✅ | Desktop application |
| Linux    | ✅ | Desktop application |

## 🔒 Security Features

- **Authentication**: Secure user authentication with Firebase Auth
- **Data Encryption**: Data encrypted in transit and at rest
- **Firestore Rules**: Server-side security rules prevent unauthorized access
- **Input Validation**: Client-side input validation and sanitization
- **Secure Storage**: Sensitive data stored securely using GetStorage

## 🚦 API Endpoints

The app uses Firebase services as the backend:

- **Authentication**: Firebase Auth REST API
- **Database**: Cloud Firestore REST API
- **Storage**: Firebase Storage (for future file attachments)

## 📈 Performance Optimizations

- **Lazy Loading**: Notes loaded on-demand with pagination
- **Caching**: Local caching with GetStorage for offline access
- **Optimistic Updates**: UI updates immediately, syncs in background
- **Image Optimization**: Compressed images for faster loading
- **Tree Shaking**: Unused code eliminated in production builds

## 🐛 Troubleshooting

### Common Issues

1. **Firebase Configuration**:
   ```bash
   # Regenerate Firebase options
   flutterfire configure
   ```

2. **Dependency Conflicts**:
   ```bash
   # Clean and reinstall
   flutter clean
   flutter pub get
   ```

3. **Build Issues**:
   ```bash
   # Clear cache
   flutter clean
   flutter pub cache repair
   ```

4. **Authentication Issues**:
   - Verify Firebase project configuration
   - Check internet connection
   - Ensure correct SHA-1 fingerprint for Android

### Debug Commands

```bash
# Verbose logging
flutter run --verbose

# Debug specific issues
flutter doctor -v
flutter analyze --verbose
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Message Convention

```
type(scope): description

feat: add new feature
fix: bug fix
docs: documentation
style: formatting
refactor: code restructuring
test: adding tests
chore: maintenance
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Your Name** - *Initial work* - [YourGitHub](https://github.com/yourusername)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend services
- GetX community for state management
- Open source contributors

## 📞 Support

If you have any questions or need help with setup, please:

1. Check the [Issues](https://github.com/your-username/notes_taking_app/issues) page
2. Create a new issue with detailed description
3. Contact the development team

---

**Made with ❤️ using Flutter and Firebase**
