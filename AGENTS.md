# Repository Guidelines

## Project Structure & Module Organization
Tuist drives the workspace (`Project.swift`, `Tuist/`), so regenerate whenever modules change. Feature code lives inside the `*Feature` directories (e.g., `HomeFeature`, `SearchFeature`), with `*FeatureLive` companions exposing concrete dependencies. Shared UI, data, and routing logic sit in `Components/`, `Models/`, `Modules/`, and `Router/RouterLive.swift`. API, persistence, and service abstractions follow the `Client`/`ClientLive` split, while `Configs` and `ConfigsLive` host runtime configuration and secrets. Tests are grouped under `Tests/<FeatureName>Tests` and mirror the module names one-to-one.

## Build, Test, and Development Commands
Run `tuist generate` after cloning to materialize the `.xcworkspace`. Use `tuist generate HomeFeatureApp --open` when iterating on a single feature-specific demo target. Launch Xcode with `xed .` and trigger archive/builds from the `Fixsy.xcworkspace`. Keep secrets in sync with `make loadSecret` (pull from secure storage) and `make saveSecret` (push local edits). Format the codebase via `make fmt`, which invokes `swiftformat .`.

## Coding Style & Naming Conventions
Swift sources use two-space indentation, trailing commas on multi-line arrays, and explicit access control when exposing APIs between modules. Name modules, targets, and directories with a `Feature` suffix (e.g., `ProfileFeature`), while live implementations add `Live` (`AccessTokenClientLive`). Prefer protocol-based clients and keep DTOs in `Models/`. Run `swiftformat` before committing; the Makefile target enforces the current style rules.

## Testing Guidelines
Unit tests rely on Tuist-generated test targets plus the Swift `Testing` DSL (`@Test`, `#expect`). Keep files suffixed with `UnitTests` (e.g., `SearchFeatureUnitTests.swift`) and co-locate helper builders inside the test type. Execute the suite locally with `tuist test Fixsy` or, when debugging Xcode schemes, `xcodebuild test -workspace Fixsy.xcworkspace -scheme Fixsy`. Aim to cover boundary logic (sorting, routing decisions, API parsing) and provide deterministic fixtures for external clients.

## Commit & Pull Request Guidelines
Follow the existing history style: short, imperative, lower-case statements (`fix localization`, `stop using binding...`). Scope one logical change per commit and mention the touched feature (`search`, `router`, etc.) in the subject. Pull requests should describe the user-facing impact, list updated modules, attach screenshots or screen recordings for UI tweaks, and link the related ticket. Ensure CI-ready branches include passing tests and formatted code before requesting review.

## Security & Configuration Tips
Never commit secrets directly—use `bin/secrets.sh get|put` through the provided Make targets. Keep `.xcconfig` overrides in `Configs/` and runtime values in `ConfigsLive/`, making sure any new keys are documented for teammates. When adding network clients, prefer using the existing `APIClient` abstraction so authentication and logging remain centralized in `AccessTokenClient`.
