# LumaSift iOS Release Notes

## 0.1.0 — Standalone iOS Companion TEST

### Included

- Public standalone repository with the repository-wide engineering and Total Automation policies.
- Enforced Master Engineering Standard and automated governance check.
- Dedicated SwiftUI companion for an owner-configured HTTPS LumaSift Windows coordinator.
- Selected-category controls for video, MP3 audio, DOCX/PDF documents, and images; live progress; exact-group review; and recoverable-quarantine confirmation.
- Typed bearer-authenticated `URLSession` client that rejects non-HTTPS coordinator URLs and does not accept NAS credentials or raw coordinator paths.
- Simulator build/test, unsigned archive, checksum, and prerelease publication automation on macOS.

### Safety and Integration Boundary

The iOS app is a review-and-approval companion. The Windows coordinator performs source scanning, sampled candidate hashing, full SHA-256 proof, deterministic plan generation, revalidation, quarantine, and purge protection. The iOS client receives only typed status/plan payloads and requests an explicit, owner-approved quarantine action.

### Distribution Status

The workflow publishes a clearly labelled simulator TEST package and unsigned XCArchive checksum evidence. It is not an App Store, TestFlight, or physical-device production build.

### Production Signing Limitation

A production iOS IPA requires an Apple distribution certificate and matching provisioning profile on macOS CI. Those credentials are intentionally absent from the repository and TEST workflow.

### Rollback

Before release publication, revert the standalone companion commit while retaining the governance baseline. After publication, use the preceding simulator TEST package or unsigned archive only for development recovery; production rollback procedures will be added after signed iOS distribution is configured.
