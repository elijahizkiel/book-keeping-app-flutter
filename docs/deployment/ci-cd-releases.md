# CI/CD & Automated Android Release Pipeline

This document details the automated GitHub Actions continuous integration and continuous deployment (CI/CD) pipeline.

---

## 1. Workflow Architecture (`.github/workflows/release-apk.yml`)

The release pipeline compiles and publishes a production Android APK on GitHub Releases.

### Triggers:
* **Branch Merges**: Push events targeting the `master` branch (including merged pull requests).
* **Manual Dispatch**: `workflow_dispatch` trigger from the GitHub Actions web interface.

---

## 2. Pipeline Execution Stages

```text
Checkout Repository
        │
Set up Temurin Java 17 & Gradle Cache
        │
Set up Flutter Stable SDK & Pub Cache
        │
flutter pub get
        │
flutter analyze (Static Code Analysis)
        │
flutter test (Unit & Widget Test Suite)
        │
flutter build apk --release
        │
Generate Release Tag (v1.0.<run_number>)
        │
Publish GitHub Release with Attached app-release.apk
```

---

## 3. Artifact Details

* **Build Output**: `build/app/outputs/flutter-apk/app-release.apk`
* **Release Artifact**: Automatically uploaded and attached to the GitHub release.
* **Release Notes**: Automatically generated from Git commits since the previous release.
