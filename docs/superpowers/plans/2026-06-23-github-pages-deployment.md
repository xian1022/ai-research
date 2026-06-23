# GitHub Pages Deployment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish the AI research homepage and four reports at stable, shareable GitHub Pages URLs.

**Architecture:** Keep the existing source reports in `projects/`, copy only the approved HTML deliverables into clean `reports/<slug>/index.html` routes, and publish the repository root from `main`. The homepage keeps local fallback paths while preferring absolute production URLs through `data-public-url`.

**Tech Stack:** Static HTML, PowerShell verification, Git, GitHub CLI, GitHub Pages

---

### Task 1: Define the public package

- [ ] Add a failing PowerShell test for four clean report routes, production URLs, `.nojekyll`, and publication exclusions.
- [ ] Run `powershell -File tests/publish.test.ps1` and confirm it fails because the public package does not exist.
- [ ] Create the four `reports/<slug>/index.html` copies and `.nojekyll`.
- [ ] Update homepage `data-public-url` values to the approved HTTPS routes.
- [ ] Run the homepage and publication tests and confirm both pass.

### Task 2: Publish the repository

- [ ] Add `.gitignore` rules that exclude source projects, work files, generated previews, and office deliverables.
- [ ] Initialize `main`, commit the public package, and create public repository `xian1022/ai-research`.
- [ ] Push `main` and enable GitHub Pages with source `{branch: main, path: /}`.

### Task 3: Verify production

- [ ] Wait until the Pages API reports `built`.
- [ ] Request the homepage and four report URLs; require HTTP 200 for each.
- [ ] Confirm the homepage title and each report's identifying heading are present.
- [ ] Re-run local tests and report the repository and Pages URLs.
