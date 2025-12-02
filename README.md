# Fixsy
Vehicle service locator and booking app for iPhone and iPad. Find nearby motorcycle garages, air pumps, wash stations, and tire patch points, read reviews, and get directions.

## Overview
- Live on the App Store: https://apps.apple.com/th/app/fixsy/id6448919715
- Maps-first experience that surfaces the nearest service spots with ratings.
- Review system helps riders choose trusted garages and quick services.
- Built with a modular Tuist workspace to keep features isolated and testable.

## Features
- Discover nearby motorcycle garages, inflating points, wash stations, and tire patch stations.
- View ratings and reviews to choose the right place.
- Map and list views with location-based sorting.
- Detail pages with directions/contact actions via the router.
- Profile and history modules for stored info and past interactions.

## Architecture
- Tuist-managed workspace (`Project.swift`, `Tuist/`) with feature modules (`*Feature`) and live implementations (`*FeatureLive`).
- Shared UI/data in `Components/`, `Models/`, and `Modules/`.
- Navigation graph in `Router/RouterLive.swift`.
- Clients follow the `Client`/`ClientLive` split (e.g., `APIClient`, `AccessTokenClient`).
- Configs live in `Configs/` with runtime values in `ConfigsLive/`.

## Getting Started
Prerequisites: Xcode (15+ recommended), Swift toolchain, and Tuist installed.

1) Install Tuist  
```bash
curl -Ls https://install.tuist.io | bash
```

2) Generate the workspace  
```bash
tuist generate
```

3) Load secrets (required values for `ConfigsLive`)  
```bash
make loadSecret
```

4) Open in Xcode  
```bash
xed .
```

5) Run the app from the `Fixsy.xcworkspace` (or use a feature demo target below).

### Feature demo targets
Generate and open a single-feature demo (example: Home):
```bash
tuist generate HomeFeatureApp --open
```

## Development
- Format: `make fmt` (runs `swiftformat .`).
- Edit Tuist manifest: `tuist edit`.
- Secrets management: `make loadSecret` to pull, `make saveSecret` to push via `bin/secrets.sh`.

## Tests
- Full suite: `tuist test Fixsy`
- Xcode scheme: `xcodebuild test -workspace Fixsy.xcworkspace -scheme Fixsy`

## Contributing
- Follow the Feature/FeatureLive naming pattern and keep DTOs in `Models/`.
- Add boundary-focused tests with the Swift `Testing` DSL (`@Test`, `#expect`) under `Tests/<FeatureName>Tests`.
- Run `make fmt` and ensure tests pass before opening a pull request.

## License
Apache-2.0 — see `LICENSE`.
