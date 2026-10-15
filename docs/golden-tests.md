# Screenshot golden tests

Screenshot tests are tagged `golden` and run in their own GitHub Actions
workflow. The ordinary deterministic test suite excludes both `integration`
and `golden` tags, so screenshot rendering does not change its timing or
coverage.

The suite uses one fixed Android phone frame at 430 × 850 pixels. It covers the
11 primary page previews, all five transport modes in a representative state,
and all seven supported states and territories for train map and stop-list
screens. Map tile layers are disabled in these fixtures so the images do not
depend on network data.

## Run comparisons

```sh
./scripts/check_goldens.sh
```

The script fails with a generation hint if the baseline folder is absent or
empty. Missing individual images also fail the screenshot test. CI only
compares committed files; it never updates them.

## Generate or refresh baselines

Run this from the repository root when intentionally changing the screenshot
fixtures or UI:

```sh
./scripts/check_goldens.sh --update-goldens test/screenshots_test.dart
```

Review the PNG changes in `screenshots/phoneScreenshots/` and commit the
approved baselines with the corresponding code change. Only PNG files in that
directory are permitted by `.gitignore`; other generated screenshot artifacts
remain ignored. The helper uses the same all-regions Dart defines for both
generation and comparison. Then run `./scripts/check_goldens.sh` to verify the
committed images.
