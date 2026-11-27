# CI/CD Setup Guide

This document describes the CI/CD pipeline for the Flutter Timetable application and provides instructions for local testing.

## Overview

The project uses GitHub Actions for CI, screenshot comparison, provider checks,
Android releases, and GitHub Pages deployment. Every Flutter setup reads the
repository version from `.fvmrc`.

## Workflows

### 1. CI (`.github/workflows/ci.yml`)

**Triggers:** Pull requests and pushes to `main`, `master`, and `dev`

**Purpose:** Runs formatting, analysis, NSW-only and all-regions tests, compares
screenshot baselines, builds debug APKs, and runs the saved-trip Android
emulator flow.

The deterministic tests exclude the separate `integration` and `golden` suites
and run with serial concurrency. Coverage artifacts are uploaded separately
for each region configuration.

### 2. Live provider tests (`.github/workflows/test.yml`)

**Trigger:** Manual dispatch with provider selections. Credentials are read
from repository secrets.

### 3. Screenshot goldens (`.github/workflows/goldens.yml`)

**Trigger:** Called by `CI` for pull requests and pushes to `main`, `master`,
and `dev`. It does not also run independently.

The screenshot job compares committed baselines with all regions enabled. It
does not update the baselines. A failed screenshot comparison fails `CI` and
blocks automatic web deployment for that commit.

### 4. Release Android APKs (`.github/workflows/release-android.yml`)

**Trigger:** Manual dispatch with a source ref and release options. No Android
signing secrets are required; APKs use the automatically generated debug key.
Releases publish immediately by default after CI passes for the exact source
commit. Provider credentials are omitted by default;
public credential distribution follows the explicit policy below.

### 5. Deploy Web (`.github/workflows/deploy-web.yml`)

**Triggers:** Successful `CI` push runs from `main` or `master`, when the
workflow run belongs to this repository. Manual dispatch is also supported on
`main` or `master`; other refs are rejected by the job guard. Both automatic
and manual deployment require the latest push `CI` run for the exact deployment
commit to have completed successfully, including screenshot comparisons. A
missing, running, cancelled, or failed run blocks the build and deployment.

The workflow checks out only trusted branch commits, builds with the pinned
Flutter SDK, and deploys through the `github-pages` environment. Provider
credentials are omitted by default.

### Public deployment credentials (Web and Android release)

The `.env` Flutter asset is downloadable from the web build and extractable
from APKs. GitHub Actions secrets become public when bundled there. A key
that must remain secret needs a server boundary; no backend proxy is included.

Both release workflows call `bash scripts/create_deployment_env.sh` to
replace `.env` with a blank `API_KEY` by default. An unset or `false`
repository variable `BUNDLE_PUBLIC_TFNSW_KEY` selects this default. To opt into
public distribution, set the variable to exactly `true` and configure the
dedicated repository secret `PUBLIC_TFNSW_API_KEY`. Invalid flag values,
missing opted-in keys, and keys containing whitespace or dotenv syntax fail
configuration before the build. The key must contain only letters, digits,
`.`, `_`, `~`, `+`, `/`, `=`, or `-`. Values are not printed.

Do not reuse a private integration key for this public deployment key. The
existing `API_KEY` secret is only for live-provider checks and is not bundled.
Other provider credentials are not automatically included.

With no bundled key, users can configure their own TfNSW key in Settings.
Their override takes priority. Local/cached data remains available, but
TfNSW requests requiring authentication need a configured key. For custom
local builds, inspect `.env` before distributing the resulting artifact.

## Local Testing Instructions

Before pushing changes, test the workflows locally to ensure they work correctly.

### Prerequisites

Install the required tools:

```bash
# Install Flutter 3.47.7 (the repository pin in `.fvmrc`)
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

### Testing CI locally

```bash
./scripts/ci.sh nsw
./scripts/ci.sh all-regions
./scripts/check_goldens.sh
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

# Build for web
flutter build web --release

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

## Pull Request Checks

The `CI` workflow reports failures for formatting, analysis, deterministic
tests, screenshot comparisons, the Android debug build, and the saved-trip
emulator flow. Configure
the repository's branch protection rules to require the `CI` check if those
results should block merging. The manually triggered live-provider and release
workflows do not run as pull-request checks.

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

Update `.fvmrc` when changing the Flutter version. GitHub Actions workflows
read that pin through `flutter-version-file`, and FVM uses it locally. The
current Flutter 3.47.7 pin bundles Dart 3.13.5 and meets the
`golden_screenshot 12.0.0` requirement (Flutter >=3.47.0, Dart >=3.13.0).

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
