# Project scripts

All commands can be run from any directory. If FVM is installed, scripts use
the Flutter version pinned in `.fvmrc`; otherwise they use `flutter` on `PATH`.

| Command | Purpose |
| --- | --- |
| `./scripts/setup.sh` | Create a local `.env` when needed and install packages |
| `./scripts/dev.sh [Flutter args]` | Run the app on an available device |
| `./scripts/dev_web.sh [Flutter args]` | Start the web development server with hot reload |
| `./scripts/format.sh` | Apply Dart formatting |
| `./scripts/lint.sh` | Check formatting and run static analysis |
| `./scripts/test.sh [test args]` | Run deterministic tests only |
| `./scripts/test_integration.sh [test args]` | Run credential-dependent integration tests |
| `./scripts/ci.sh` | Reproduce the GitHub Actions quality job locally |
| `./scripts/build_web.sh [build args]` | Create a release web build |
| `./scripts/build_apk.sh [build args]` | Create a release Android APK |
| `./scripts/test_cicd.sh [web\|android\|all]` | Run CI checks and selected production builds |
| `PORT=8000 ./scripts/preview_web.sh` | Build and serve the production web app |
| `./scripts/generate_api.sh` | Regenerate API clients with build_runner |
| `./scripts/clean.sh` | Clean Flutter outputs and restore packages |

The development web server listens on port `8080` by default. Override its
address with environment variables, for example:

```bash
PORT=3000 ./scripts/dev_web.sh
```

It binds to `127.0.0.1` so Flutter's browser debugging URLs remain valid. Set
`WEB_HOSTNAME=0.0.0.0` explicitly when access from other machines is needed.

Integration tests need valid provider credentials in `.env`. Android release
builds also require an installed Android SDK and a compatible Java toolchain.
