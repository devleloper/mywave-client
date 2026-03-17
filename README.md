# 🌊 MyWave - Audio Streaming Client

![Flutter](https://img.shields.io/badge/Flutter-Cross--Platform-00AEFF?logo=flutter)
![BLoC](https://img.shields.io/badge/State_Management-BLoC-blue)
![Architecture](https://img.shields.io/badge/Architecture-Clean-success)
![License](https://img.shields.io/badge/License-Proprietary-red)

MyWave is a high-performance, cross-platform (Web, iOS, Android) audio streaming client designed to interface with custom REST APIs. Built with a strict Clean Architecture approach and enterprise-grade code quality, MyWave delivers a seamless, premium auditory and visual experience.

Unlike traditional commercial streaming apps, MyWave operates as a standalone, white-label frontend client. It focuses on manual library management, privacy, and an anonymous profile system, allowing users to connect to their own compatible media servers or private endpoints.

## ✨ Key Features

* **Custom Media Source Integration:** Connect the client to your preferred compatible API endpoint via a user-provided Access Token.
* **Context-Aware Audio Player:** Smart playback queue that adapts to your context. Play from an Album for a strict tracklist order, or play from an Artist for a continuous mix, depending on API support.
* **Offline Mode:** Download tracks directly to your device. Metadata is securely stored locally in an encrypted database for seamless offline access.
* **Custom "Tiffany" UI:** A completely bespoke user interface rejecting standard Material design. Features fluid bounce animations, dynamic Light/Dark themes, and a signature "Liquid Glass" navigation bar.
* **Advanced Routing:** Deep, complex navigation stacking (`Album -> Artist -> Album -> Track`) using `go_router` without losing application state.

## 🏗 Architecture & Tech Stack

The project strictly follows **Clean Architecture** principles, dividing the codebase into `domain`, `data`, and `presentation` layers to ensure maximum scalability and testability.

* **Framework:** Flutter (Cross-platform)
* **State Management:** `flutter_bloc`
* **Routing:** `go_router`
* **Network:** `dio` (with custom interceptors for token injection)
* **Storage:** `flutter_secure_storage` (for API tokens and sensitive data) & Local DB for downloaded metadata.
* **Dependency Injection:** Configured for high performance and modularity.

## 📂 Project Structure

```text
lib/
├── core/               # App-wide constants, errors, and DI setup
├── domain/             # Entities, Repositories (Interfaces), UseCases
├── data/               # Models, Repositories (Implementations), API Clients
└── presentation/       # UI Layer
    ├── theme/          # Custom Tiffany color scheme, Typography, Animations
    ├── widgets/        # Global reusable widgets (Liquid Glass Nav, Bounce Buttons)
    └── features/       # Feature-driven structure (auth, home, search, player, collection)
        └── [feature]/
            ├── view/   # UI Screens
            ├── bloc/   # State Management
            └── widgets/# Feature-specific widgets
```

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (Latest stable version)
* A valid compatible API endpoint URL and Access Token (required during onboarding)

### Installation
1. Clone the repository:
   ```bash
   git clone <repository_url>
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## ⚖️ Disclaimer
MyWave is developed strictly as a frontend client application and portfolio piece. The repository does not contain, host, or distribute any copyrighted media content, nor does it provide direct access to specific commercial streaming services out of the box. Users are solely responsible for the endpoints and data they connect to this client.

---

## Copyright and License

**Copyright (c) 2026 Devlet Boltaev (devleloper). All rights reserved.**

The source code for **MyWave** (including this repository, currently known as `mywave-client`) is proprietary intellectual property. It is made available on GitHub strictly for viewing, portfolio demonstration, and contributing to this specific repository.

**You are allowed to:**
* **Read and inspect** the source code.
* **Fork** the repository *strictly* for the purpose of submitting Pull Requests back to this original repository.

**You are STRICTLY PROHIBITED from:**
* **Copying, duplicating, or reusing** the code, architecture, or assets (in whole or in part) in your own or third-party projects.
* **Distributing, mirroring, or publishing** the code elsewhere.
* **Using the code** for any commercial, non-commercial, or personal purposes outside of contributing to this original repository.

**Third-Party Packages:** This proprietary license applies to all original MyWave code. Third-party dependencies downloaded from `pub.dev` remain under their respective open-source licenses (e.g., MIT, Apache 2.0).

**Enforcement:** Any unauthorized use, reproduction, or distribution of this code constitutes copyright infringement. Violations will be subject to immediate **DMCA takedown notices** without prior warning and potential legal action.