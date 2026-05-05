# CLAUDE.md — Eugo Triton Fork

This is **eugo-inc's fork** of [triton-lang/triton](https://github.com/triton-lang/triton). The fork is deliberately narrowed to **CUDA only** — AMD/ROCm/HIP code paths are stripped out or disabled. The primary maintenance task in this repo is **periodically merging upstream `main`** without breaking our CUDA-only constraints.

This document exists so that anyone (human or Claude) merging from upstream knows:

1. The `@EUGO_CHANGE` convention (so our edits survive the merge).
2. The exact dev workflow for a merge (we **merge**, never **rebase**).
3. What to expect during conflict resolution.

---

## 1. The `@EUGO_CHANGE` convention

Every edit we make to upstream files **must** be tagged with the literal string `@EUGO_CHANGE`. This is what makes upstream merges tractable — without the marker, our changes are invisible against thousands of upstream lines.

### Rules

- **Tag every edit.** Any line we add, modify, or comment-out in a file that came from upstream must carry `@EUGO_CHANGE` somewhere on (or immediately above) the change.
- **Prefer commenting-out over deleting.** When we remove an upstream line, comment it out and tag the comment, e.g. `# MLIRAMDGPUDialect # @EUGO_CHANGE - no AMD support`. This makes the diff against upstream readable and the change reversible during a merge.
- **Brief reason after the marker.** Use the form `@EUGO_CHANGE - <short reason>` or `@EUGO_CHANGE: <short reason>`. The reason is what tells you, six months later, whether to keep the change when upstream has rewritten the surrounding code.
- **Block markers for multi-line regions.** When the change spans more than one line, bracket the region with `# @EUGO_CHANGE: @begin <reason>` and `# @EUGO_CHANGE: @end`. The `@begin` line carries the reason; the `@end` line just closes the block. This is the canonical form — older `# === @begin: ... @EUGO_CHANGE ===` markers from earlier in the fork's history should be normalized to this form whenever you touch them.
- **Wholly Eugo-owned files** (e.g. [eugo_wrapper.cmake](eugo_wrapper.cmake), [.eugo/eugo_pip3_install.sh](.eugo/eugo_pip3_install.sh), this `CLAUDE.md`) only need a single `@EUGO_CHANGE` at the top — every line is ours.
- **Comment syntax matches the file.** `#` for Python/CMake/TOML/shell, `//` for C/C++, `<!-- ... -->` for Markdown/HTML.

### Quick examples

Single-line edit, marker inline:

```cmake
option(EUGO_TRITON_BUILD_APPS "Build CLI apps from ./bin" OFF) # @EUGO_CHANGE: added to gate ./bin builds
```

Single-line deletion, commented out and marked:

```cmake
# MLIRAMDGPUDialect # @EUGO_CHANGE - no AMD support
```

Multi-line region, bracketed:

```cmake
# @EUGO_CHANGE: @begin keep exceptions + RTTI propagated
set(TRITON_DISABLE_EH_RTTI_FLAGS "")
# @EUGO_CHANGE: @end
```

Wholly-owned file, single header marker:

```toml
# @EUGO_CHANGE
[tool.scikit-build]
install.strip = false
```

### Finding our changes

```bash
# Every file we've touched:
git grep -l "@EUGO_CHANGE"

# Every individual change with surrounding context:
git grep -n "@EUGO_CHANGE"
```

This grep is the single source of truth for "what did we change?" — keep it accurate.

---

## 2. Repository layout for merges

### Remotes

```
origin    https://github.com/eugo-inc/triton-4947a95.git   (our fork)
upstream  https://github.com/triton-lang/triton.git        (upstream)
```

If `upstream` is missing on a fresh clone, add it:

```bash
git remote add upstream https://github.com/triton-lang/triton.git
```

### What is and isn't ours

- **Eugo-owned files** (entirely ours, never in upstream): [eugo_wrapper.cmake](eugo_wrapper.cmake), this `CLAUDE.md`.
- **Modified upstream files**: tagged with `@EUGO_CHANGE` — primarily [CMakeLists.txt](CMakeLists.txt), [pyproject.toml](pyproject.toml), [test/CMakeLists.txt](test/CMakeLists.txt), [test/lib/CMakeLists.txt](test/lib/CMakeLists.txt), and several files under [third_party/proton/](third_party/proton/) and [third_party/amd/](third_party/amd/) (where AMD support is disabled).
- **Posterity files** named `__eugo_version_for_posterity_*` under [bin/](bin/) — snapshots we keep to reason about upstream drift. Don't delete during a merge unless explicitly intended.

### The CUDA-only invariant

Anything that re-enables AMD/ROCm/HIP code paths is a **regression**, even if it merges cleanly. During every merge, double-check that:

- AMD-related `add_subdirectory`, `link_libraries`, dialect registrations remain commented out with their `@EUGO_CHANGE` markers.
- New upstream files under `third_party/amd/` are *not* added to our build (they may sit on disk untouched, but should not be wired into CMake).
- New ROCm/HIP-conditional code in shared files (e.g. `third_party/proton/`) is gated off behind our `@EUGO_CHANGE` comments.

### Build-flag policy (don't drift)

Upstream is opinionated about C++ build flags in ways that don't suit us. Our overrides live in [CMakeLists.txt](CMakeLists.txt) inside the `if(NOT MSVC)` block under `# Disable warnings that show up in external code`, marked with `@EUGO_CHANGE`. Preserve them on every merge:

- **No `-Werror`.** Warnings stay warnings — never hard build failures. We add `-Wno-error` defensively in case `-Werror` slips back in via another path.
- **No `-fno-exceptions` / `-fno-rtti`.** Exceptions and RTTI must propagate. We force `TRITON_DISABLE_EH_RTTI_FLAGS` to empty (upstream applies it per-target via `target_compile_options(... ${TRITON_DISABLE_EH_RTTI_FLAGS})` inside `add_triton_library`).
- **No `-fvisibility=hidden`.** We want default symbol visibility for `libtriton.so`.
- **Keep `-Wno-covered-switch-default`.** Clang-only warning suppression for `default:` cases in fully-covered enum switches — harmless.
- **Never set `TRITON_EXT_ENABLED=ON`** as a shortcut to skip `-fvisibility=hidden`. It also defines the preprocessor macro `TRITON_EXT_ENABLED=1`, which gates plugin-loader compatibility checks in upstream code (commits `8497c845af`, `6cb844590c`). We don't load Triton plugins, so it's all downside.

If upstream restructures this block, port the four overrides above into the new structure with fresh `@EUGO_CHANGE: @begin/@end` markers. The user has been explicit that this set of preferences is non-negotiable.

---

## 3. Dev workflow: merging from upstream

**We merge. We do not rebase.** Rebasing rewrites our commits and makes future merges harder; merge commits preserve history and let `git log --first-parent` show the Eugo-side timeline cleanly.

### Step-by-step

```bash
# 1. Make sure your local main is clean and up to date with our origin.
git checkout main
git pull --ff-only origin main
git status   # must be clean — no untracked files, no staged changes

# 2. Fetch the latest from upstream.
git fetch upstream

# 3. Create a dedicated merge branch off our main.
#    Name it after the upstream tip you're merging in for traceability.
UPSTREAM_SHA=$(git rev-parse --short upstream/main)
git checkout -b "merge-upstream-${UPSTREAM_SHA}"

# 4. Perform the merge. DO NOT use --rebase. DO NOT use --squash.
#    The default --no-ff merge commit is what we want.
git merge upstream/main
```

If the merge is clean, jump to **Step 7**. Otherwise:

### 5. Resolving conflicts

Conflicts will almost always show up in files we've tagged with `@EUGO_CHANGE`. The rule of thumb:

- **Keep our `@EUGO_CHANGE` lines** unless upstream has fundamentally restructured the surrounding code such that the change is no longer meaningful.
- **Re-tag if you re-apply.** If upstream rewrote the area and you have to manually re-disable AMD support in a new location, add a fresh `@EUGO_CHANGE` comment with a reason.
- **Drop only with intent.** If you remove an `@EUGO_CHANGE` because upstream now does the same thing natively (e.g. upstream gated AMD behind their own option), note it in the merge commit body so future readers can audit.

Useful while resolving:

```bash
# What did we change in this file vs. upstream pre-merge?
git log --oneline origin/main -- <file>

# Show our @EUGO_CHANGE lines in a conflicted file:
git grep -n "@EUGO_CHANGE" -- <file>

# Abort if you got lost; nothing is committed yet.
git merge --abort
```

After resolving each file:

```bash
git add <file>
```

When all conflicts are resolved:

```bash
git commit   # uses the auto-generated merge message — edit the body to list any non-trivial reconciliations
```

### 6. Sanity-check the CUDA-only invariant

Before pushing, verify our markers and CUDA-only stance survived:

```bash
# Spot-check the count and locations of our markers — should be similar to before the merge.
git grep -c "@EUGO_CHANGE"

# Confirm AMD/ROCm aren't accidentally re-enabled. These should still be commented or absent:
git grep -n "MLIRAMDGPUDialect\|LLVMAMDGPUCodeGen\|__HIP_PLATFORM_AMD__"

# Build sanity: we don't need the full build to succeed in this repo for the merge PR,
# but the CMake configure step should at least not fail outright.
```

Inspect [eugo_wrapper.cmake](eugo_wrapper.cmake) — it survives a merge cleanly because upstream doesn't touch it, but verify it's still `include()`-d from [CMakeLists.txt](CMakeLists.txt) at the `# === @begin: Eugo wrapper @EUGO_CHANGE ===` block.

### 7. Push and open a PR

```bash
git push -u origin "merge-upstream-${UPSTREAM_SHA}"
gh pr create --base main --title "merge: upstream@${UPSTREAM_SHA}" --body "..."
```

PR description should call out:

- Which upstream SHA range was merged (`git log --oneline ${OLD_BASE}..upstream/main` summarized).
- Any `@EUGO_CHANGE` markers added, removed, or relocated.
- Any CUDA-only-invariant near-misses you noticed.

**Merge the PR with a merge commit, not squash, not rebase.** GitHub's "Create a merge commit" preserves the upstream history we just pulled in.

---

## 4. Things that will trip you up

- **`pyproject.toml` version pin.** [pyproject.toml](pyproject.toml) carries a `# @TODO+: Keep in sync with upstream version` note next to `version = "3.2.0"`. Bump it when upstream bumps theirs — this has bitten us before (see [d91e4667](#) "fix: wrong version of upstream in pyproject.toml").
- **Files under `bin/__eugo_version_for_posterity_*`** look unfamiliar but are deliberate. Don't delete them during a merge unless you know why.
- **`third_party/amd/` and `third_party/proton/` AMD bits.** Upstream actively develops these. Most merges will land changes here that need to be neutered with fresh `@EUGO_CHANGE` comments rather than accepted as-is.
- **`.gitignore` churn from upstream.** Upstream has historically reorganized ignores in ways that lose files we depend on. The `install(DIRECTORY ...)` calls in [eugo_wrapper.cmake](eugo_wrapper.cmake) defend against this — keep them in sync if upstream's package layout shifts.
- **Don't run `git rebase` reflexively.** If you're tempted to rebase to "clean up" the merge branch, stop. The merge commit is load-bearing.
