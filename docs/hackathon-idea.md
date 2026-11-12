<!--
DRAFT for the Directions EMEA 2026 hackathon (template: "Hackathon Project Idea").
Issue title: [Hackathon Idea] BC Open Store – discover, verify and safely install open-source Business Central apps
Before submitting (deadline Dec 1st 2026, noon CET): read the Reflection and make sure it sounds like you; confirm the working title.
-->

## 🧠 Reflection

Directions is about where the Business Central ecosystem is heading, and for me one piece is still missing: **open source that customers can actually use.**

Today there are two kinds of open-source BC apps. If you're a registered ISV, like me, you can publish your app on AppSource for free, and customers can install it with one click. Most community developers can't do that. Their only option is to push the app to GitHub, usually in the 50000 range that every customer already uses.

But GitHub is a developer portal, not a place where customers get apps. A customer can't find, install or update an app from GitHub without a developer doing it for them. AI makes the coding part a bit easier, but everything around it is still manual: finding the app, renumbering it, installing it, updating it, deciding whether to trust it. So most good open-source AL code never reaches a customer tenant, and open source in BC stays something developers share with each other.

This is the app I believe is needed, and the one I want to contribute: a tool that closes that gap, so end users and customers get the real benefits of open source, and every community developer can reach them, not just those with an AppSource listing.

---

## 💡 Project Idea

**BC Open Store**: an extension (distributed through AppSource) that turns GitHub into an app store for open-source Business Central apps, **with a trust pipeline built in**.

**The problem:** there are many useful open-source BC apps, but customers almost never install them:
1. **Nobody can find them.** There's no catalog; you only find them if you know the repository.
2. **Their ID ranges collide.** Almost all of them use the per-tenant extension range (50000–99999), which every customer already uses for their own extensions. In SaaS, apps with any other range can't be uploaded as a PTE at all.
3. **Nobody knows whether to trust them.** Installing code from a stranger into production with no review, no tests and no update process isn't acceptable.

**The idea:**
- **Discovery:** maintainers add a GitHub topic to their repository and publish GitHub releases (which AL-Go already does). A central registry (GitHub Action) crawls those repositories and builds a static `index.json` with versions, license, dependencies, ID ranges and hashes. The store in BC reads that index and shows a storefront (tiles, details, versions).
- **Renumbering inside Business Central:** before installing, the store unpacks the `.app` package in AL and moves all objects into a free ID range on the tenant. That means object declarations, table/enum extension fields and values, IDs hidden in strings, `SymbolReference.json`, `navigation.xml` and the manifest. Then it repacks the app and installs it. The ID mapping is **stored**, so every update gets the same IDs and the customer's data survives. The server compiles the repacked source when it's published, so no external compiler is needed. There is precedent for this: Erik Hougaard's *Simple Object Designer* builds `.app` packages in AL and publishes them in Business Central SaaS.
- **Trust pipeline:**
  - **Facts scan:** reads the source and lists what the app can do: outbound HTTP hosts, subscribers on sensitive events, changes to standard data in install/upgrade code, permission sets, job queue entries and more. Shown like app permissions on a phone.
  - **AI review:** an LLM explains those facts and checks whether they fit what the app claims to do. Every finding cites file and line; the code is treated as untrusted input (it's built to resist prompt injection). For updates, only the diff is reviewed. The AI review helps a person decide; it doesn't replace them.
  - **Tests:** contributors ship test apps alongside their release. Results from CI (and later from the customer's own sandbox) are shown in the store.
  - **Sandbox first:** a policy can require that the exact same version (same hash) ran in a sandbox before it can go to production. Production takes the ID mapping from the sandbox, so both environments match.
- **Updates and hotfixes:** stable/prerelease channels, an update policy per app (notify / sandbox auto / production after soak time), and the registry can **withdraw** a version (warning plus install block, like "yank" in npm). Fast-changing rules live in the registry as data, so they don't wait for an AppSource release.

**Why it matters for the ecosystem:** open-source BC code becomes something customers can actually use, maintainers get distribution for free, and partners get a reviewable, controlled way to bring community apps into production.

---

## 🛠️ Implementation Plan

Everything is built test-first (red/green). The renumbering engine is tested against real open-source apps as test data. Every bug found becomes a regression test with that exact app.

| # | Milestone | Content |
|---|-----------|---------|
| 0 | De-risk spike ✅ **done** | Building and publishing an app package from AL inside Business Central works, so the feasibility risk is resolved. BC has no record of the original IDs: a renumbered package is simply a new app to it. Whether renumbering is *correct* is handled by tests in milestone 1. |
| 1 | Repack engine | AL codeunits: read and write the NAVX package (40-byte header, zip, content length, remove signature); renumber that understands strings and comments in `.al`, plus `SymbolReference.json`, `navigation.xml` and the manifest; warn about any leftover number in the old range that it isn't sure about. |
| 2 | Registry | GitHub Action: topic crawler → `index.json` (versions, SHA-256, license filter (OSI licenses only), ID ranges, dependencies, BC version compatibility) + facts scan + automatic repack test of every listed app. |
| 3 | Store in BC | Storefront (Brick tiles + card page), choose a free range, mapping table (shared by all companies), install through Extension Management incl. tracking the deployment status, update detection. |
| 4 | Trust | AI review in the registry (diff-based for updates), "What this app can do" panel, sandbox-first policy (Admin Center API), withdrawn versions. |
| 5 | Ecosystem & demo | Onboard 5–10 real open-source BC apps, maintainer documentation (`topic + release` is all it takes), demo script. |

**MVP:** milestones 1–5 (0 is already done).
**Stretch:** running contributor test apps inside the customer's sandbox, a Copilot review inside the tenant (aware of the customer's other extensions), a version diff view, NuGet as a second source (behind a `Store Source` interface), a ControlAddIn storefront, chains of dependent store apps.

**Questions to settle early:** whether AppSource policy allows a store app that installs PTEs (I'll ask Microsoft early); whether to keep or change app IDs when repacking; how repacked apps are versioned (so I can hotfix the repacker itself, since BC can't downgrade).

---

## 👥 Team

> - Stefan Maron (@StefanMaron)

---

## 🚀 Expected Outcome

- An **open-source BC extension** (store + repack engine) on GitHub, ready to be published on AppSource.
- An **open-source registry** (GitHub Action + public `index.json`) that any maintainer can join by adding a topic.
- A **live demo:** a tenant whose 50000 range is already used → browse → facts + AI review + test results → install in a sandbox, which renumbers automatically → move to production → publish v1.1 on GitHub → update keeps the data.
- Documentation for maintainers and admins, and a test suite running against real community apps.

---

## 🗓️ Timeline Overview
| Phase | Description | Target Date |
|-------|--------------|--------------|
| Ideation & Submission | Reflect and submit by noon, Dec 1st (spike already done: renumbered app installs) | Dec 1st |
| Development | M1 Repack engine | Dec 14th |
| Development | M2 Registry + facts scan | Dec 31st |
| Development | M3 Store in BC (browse, install, update) | Jan 14th |
| Development | M4 AI review, sandbox-first policy, withdrawn versions | Jan 25th |
| Finalization & Submission | M5 Onboard real apps, docs, demo; submit project | Feb 1st |
| Review & Selection | Projects reviewed | Feb 2nd – Mar 1st |
| Directions Webinar | Presentation + Winner announcement | Mar 2nd |
