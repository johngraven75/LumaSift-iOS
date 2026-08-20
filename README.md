# LumaSift for iOS

LumaSift for Ios is an authenticated iOS companion to a trusted LumaSift Windows coordinator. It helps an owner identify exact duplicate media and document files safely: videos, MP3 audio, DOCX documents, PDFs, and images.

## Safety Contract

LumaSift may use a sampled hash to discover collision candidates, but it must calculate a **full SHA-256 hash** before a duplicate group is actionable. It retains the highest-ranked exact copy, proposes lower-ranked copies for **recoverable quarantine**, and requires a separate explicit purge action.

## Engineering Governance

This repository is governed by [AGENTS.md](AGENTS.md), the [Total Automation Policy](.github/AUTOMATION_POLICY.md), and the [Master Engineering Standard](.github/MASTER_ENGINEER_STANDARD.md). The automated governance workflow fails if the required engineering and release artifacts are missing.

## Coordinator Connection

The iOS application is a **review-and-approval companion** for an owner-configured, trusted LumaSift Windows coordinator. It requires an `https://` coordinator address and an owner-provided bearer token. It exposes selected file categories, progress, exact-group review data, and quarantine confirmation; it does not receive NAS credentials or raw source paths.

## Development and Validation

| Check | Command |
| --- | --- |
| Governance | `python3 scripts/verify_governance.py` |
| Xcode project generation | `xcodegen generate` |
| Simulator tests | `xcodebuild -project LumaSift.xcodeproj -scheme LumaSift -sdk iphonesimulator test` |

The hosted macOS workflow generates the project, builds and tests the simulator app, creates an unsigned archive, stages a Simulator TEST package, writes checksums, and publishes a labelled prerelease.

## Current Delivery Scope

The repository targets a clearly labelled simulator TEST package and unsigned archive unless Apple distribution signing is configured. App Store, TestFlight, or physical-device distribution needs an Apple distribution certificate and matching provisioning profile. See [RELEASE_NOTES.md](RELEASE_NOTES.md) for current limitations and [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the platform boundary.
