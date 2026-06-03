# Contributing Guide

Thank you for your interest in contributing to this project.

> **Note:** This repository distributes a pre-built binary framework. Contributions are welcome for documentation, issue reporting, and `Package.swift` fixes. Source code contributions are managed in a separate internal repository.

## Contributing Workflow

1. **Optional: Start with an Issue**
   Whether you are reporting a bug or requesting a new feature, it's always best
   to check if someone else has already opened an issue for it! If the bug or
   feature is small and you'd like to take a crack at it, go ahead and skip this step.

2. **Fork the Repository**
   Fork the repository by clicking the "Fork" button in the top right corner of
   the repository page. This will create a copy of the repository in your GitHub
   account. Then, clone your forked repository to your local machine and create a
   branch for your changes.

3. **Version Pinning Policy**
   Consumers must depend on the SDK using exact version pinning (`.exact("x.y.z")`).
   Range-based specifiers (`from:`, `.upToNextMajor`, `.upToNextMinor`) are not
   supported because the SDK ships a pre-built binary framework whose checksum is
   tied to each release. Range resolution may resolve to a version whose binary
   checksum has not been verified, causing build failures.

4. **Development Workflow**
   These are the high level steps to contribute changes:
   - Setup your development environment
   - Implement your change
   - Test your change manually, and include unit tests if applicable
   - Write docs for your change

5. **Pull Request Process**
   Once you have your changes ready, there are a few more steps to open a PR and
   get it merged:
   - Fill out the PR template completely with as much detail as possible
     - Ideally, include screenshots or videos of the changes in action
   - Link related issues, if any
   - Ensure all CI checks are passing

6. **PR Review Expectations**
   Once your PR is open, you can expect an initial response acknowledging receipt
   of the PR within 1-3 business days, and an initial review within 1-2 business
   day from a maintainer assigned to your PR. Once all comments are addressed and
   a maintainer has approved the PR, it will be merged by the maintainer and
   included in the next release.
