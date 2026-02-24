# CI/CD Setup Guide

This document describes the CI/CD pipeline for the Flutter Timetable application and provides instructions for local testing.

## Overview

The project uses GitHub Actions for continuous integration and deployment with four main workflows:

1. **Test Suite** (`test.yml`) - Runs tests on pull requests and pushes
2. **Build APK** (`build-apk.yml`) - Builds Android APK files
3. **Release APK** (`release-apk.yml`) - Publishes APK as GitHub release on master
4. **Deploy Web** (`deploy-web.yml`) - Deploys Flutter web app to GitHub Pages

## Workflows

### 1. Test Suite (`.github/workflows/test.yml`)

**Triggers:** Pull requests and pushes to `master` and `dev` branches

**Purpose:** Runs the test suite, formatting checks, and static analysis

**Configuration:**
- Currently set to `continue-on-error: true` to allow failures without blocking
- To re-enable blocking on failures: Remove the `continue-on-error: true` line

**Steps:**
1. Checkout code
2. Setup Flutter (v3.27.0)
3. Get dependencies
4. Verify formatting
5. Analyze project source
6. Run tests

### 2. Build APK (`.github/workflows/build-apk.yml`)

**Triggers:** Pull requests and pushes to `master` and `dev` branches

**Purpose:** Builds both release and debug APK files

**Outputs:**
- Release APK: `lbww_flutter-{version}-release.apk`
- Debug APK: `app-debug.apk`
- Artifacts retained for 30 days (release) / 7 days (debug)

**Steps:**
1. Checkout code
2. Setup Java 17 and Flutter
3. Get dependencies
4. Create `.env` file from template
5. Build release and debug APKs
6. Upload as artifacts

### 3. Release APK (`.github/workflows/release-apk.yml`)

**Triggers:** Pushes to `master` branch only

**Purpose:** Creates a GitHub release with the APK file

**Outputs:**
- GitHub Release with tag `v{version}-{build_number}`
- Release APK attached to the release
- Artifacts retained for 90 days

**Steps:**
1. Checkout code
2. Setup Java 17 and Flutter
3. Build release APK
4. Create GitHub release
5. Upload APK to release

**Note:** This workflow is independent of the web deployment workflow.

### 4. Deploy Web (`.github/workflows/deploy-web.yml`)

**Triggers:** Pushes to `master` branch only

**Purpose:** Builds and deploys the Flutter web app to GitHub Pages

**Configuration:**
- Uses concurrency control to prevent deployment conflicts
- Requires GitHub Pages to be enabled in repository settings
- Uses HTML renderer for better compatibility

**Steps:**
1. Build job:
   - Checkout code
   - Setup Flutter
   - Enable Flutter web
   - Build web app
   - Upload artifacts
2. Deploy job:
   - Deploy to GitHub Pages
   - Runs independently after build completes

**Note:** This workflow is independent of the APK release workflow.

## Local Testing Instructions

Before pushing changes, test the workflows locally to ensure they work correctly.

### Prerequisites

Install the required tools:

```bash
# Install Flutter (version 3.27.0 or compatible)
# See: https://docs.flutter.dev/get-started/install

# Install Java 17 (for Android builds)
# Ubuntu/Debian:
sudo apt-get install openjdk-17-jdk

# macOS (using Homebrew):
brew install openjdk@17

# Verify installations
flutter --version
java -version
```

### Testing the Test Workflow

```bash
# Get dependencies
flutter pub get

# Run formatting check
dart format --output=none --set-exit-if-changed .

# Run static analysis
flutter analyze

# Run tests
flutter test
```

### Testing APK Build

```bash
# Ensure you have the .env file
cp .env.template .env

# Build release APK
flutter build apk --release

# Build debug APK
flutter build apk --debug

# Check the output
ls -lh build/app/outputs/flutter-apk/

# Test on device or emulator
# Install the APK:
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Important:** Test the APK on an actual device or emulator to ensure:
- The app launches correctly
- All features work as expected
- No runtime errors occur
- Assets are properly bundled

### Testing Flutter Web Build

```bash
# Enable Flutter web
flutter config --enable-web

# Get dependencies
flutter pub get

# Ensure you have the .env file
cp .env.template .env

# Build for web (using HTML renderer for compatibility)
flutter build web --release --web-renderer html

# Check the output
ls -lh build/web/

# Test locally using a web server
cd build/web
python3 -m http.server 8000
# Then open http://localhost:8000 in your browser
```

**Important:** Test the web build thoroughly:
- Test in multiple browsers (Chrome, Firefox, Safari, Edge)
- Check responsive design on different screen sizes
- Verify all functionality works in the web environment
- Check browser console for errors
- Test on both desktop and mobile browsers
- Verify assets load correctly
- Check that API calls work (CORS issues, etc.)

### Testing CI Workflow Syntax

```bash
# Install act (for local GitHub Actions testing)
# See: https://github.com/nektos/act

# Validate workflow syntax
for file in .github/workflows/*.yml; do
  echo "Validating $file"
  # Basic YAML validation
  python3 -c "import yaml; yaml.safe_load(open('$file'))"
done
```

## GitHub Pages Setup

To enable GitHub Pages deployment:

1. Go to repository Settings → Pages
2. Set Source to "GitHub Actions"
3. Wait for the first deployment to complete
4. Access your app at: `https://{username}.github.io/{repository-name}/`

## Enabling Test Blocking

Currently, tests are configured to not block CI/CD workflows. To enable blocking:

1. Open `.github/workflows/test.yml`
2. Remove the line `continue-on-error: true` from the test job
3. Commit and push the change

This will cause pull requests to be blocked if:
- Code formatting is incorrect
- Static analysis finds issues
- Tests fail

## Troubleshooting

### APK Build Fails

- Ensure Java 17 is installed
- Check that `android/app/build.gradle` has correct configuration
- Verify that all dependencies are compatible with the Flutter version
- Check for signing configuration issues

### Web Build Fails

- Ensure Flutter web is enabled: `flutter config --enable-web`
- Check for web-incompatible plugins (file system access, etc.)
- Verify that `web/index.html` exists and is properly configured
- Check browser console for runtime errors

### Tests Fail

- Run tests locally first: `flutter test`
- Check for missing dependencies
- Verify test fixtures and mock data
- Review test logs for specific failures

### Deployment Issues

**APK Release:**
- Ensure `GITHUB_TOKEN` has sufficient permissions
- Check that version numbers are properly formatted in `pubspec.yaml`
- Verify release artifacts are being created

**GitHub Pages:**
- Ensure GitHub Pages is enabled in repository settings
- Check that Pages source is set to "GitHub Actions"
- Verify deployment permissions in Actions settings
- Check that the workflow has `id-token: write` permission

## Maintenance

### Updating Flutter Version

Update the Flutter version in all workflow files:

```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.27.0'  # Update this version
    channel: 'stable'
```

### Updating Java Version

Update the Java version in APK workflows:

```yaml
- name: Setup Java
  uses: actions/setup-java@v4
  with:
    distribution: 'zulu'
    java-version: '17'  # Update this version
```

## Best Practices

1. **Always test locally** before pushing changes that affect workflows
2. **Test APK on real devices** to catch issues that emulators might miss
3. **Test web builds in multiple browsers** to ensure compatibility
4. **Monitor CI/CD runs** after pushing changes
5. **Keep dependencies updated** to avoid security vulnerabilities
6. **Review release notes** before updating Flutter or dependencies
7. **Use feature branches** and pull requests for all changes
8. **Enable test blocking** once test suite is stable

## Additional Resources

- [Flutter CI/CD documentation](https://docs.flutter.dev/deployment/cd)
- [GitHub Actions documentation](https://docs.github.com/en/actions)
- [Flutter web deployment](https://docs.flutter.dev/deployment/web)
- [Android app signing](https://docs.flutter.dev/deployment/android#signing-the-app)
