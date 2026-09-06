# C++ GDB Debug — Test Cheat Sheet (demo `~/debug_cpp`)

Manual checklist to run after the automated suite
(`bash test/test_gdb_workflow.sh`) passes.

No custom keybindings. No completions in GDB buffers.
One entry point: `M-x my/cpp-debug`.

## 0. Deps

```sh
gdb --version
rr --version
cmake --version
emacs --version
```

## 1. Debug any project (the whole workflow)

```text
M-x my/cpp-debug RET <binary>   # smart default: newest executable under build/
```

This builds Debug (`cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug &&
cmake --build build`) and launches `gdb -i=mi` with pretty-printing
(values, arrays, indexes, unlimited elements) already applied.
Root auto-detection climbs to the outermost `project()` CMakeLists,
so calling from a subdirectory still builds the top-level project.
If switching from a Release cache: `rm -rf build` first.

## 2. Drive GDB (built-in abbreviations, typed in console)

| Type | Command    | Type | Command          |
|------|------------|------|------------------|
| `b`  | break      | `n`  | next (over)      |
| `s`  | step (in)  | `c`  | continue         |
| `f`  | finish     | `p`  | print value      |
| `bt` | backtrace  | `q`  | quit             |
| `rn` | reverse-next | `rs` | reverse-step   |
| `rc` | reverse-continue | `record stop` | stop recording |

Deref recipes:

```text
(gdb) p *res
(gdb) p *res2
(gdb) p safe_null
(gdb) p v                 # shows active alternative: [0] = "variant demo"
```

## 3. CLI sanity (no Emacs, same behavior)

```sh
cd ~/debug_cpp
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug && cmake --build build
file build/debug_demo   # expect: with debug_info
gdb -batch ./build/debug_demo \
  -ex 'break demonstrate_smart_ptr' -ex run \
  -ex 'next' -ex 'print *res' -ex continue -ex quit
# expect: id_ = 42
```

## 4. `record` (best-effort)

```text
(gdb) record
(gdb) rn
(gdb) record stop
```

May fail on some syscalls/AVX/aarch64 — fall back to forward debug.

## 5. `rr` (x86_64-focused)

```sh
rr record ./build/debug_demo
rr replay
```

On aarch64 a failure is architecture (suspect #1), not config.

## 6. If red

| Symptom | Fix |
|---------|-----|
| No symbols | `rm -rf build`, rebuild Debug |
| Pretty-print missing | `info pretty-printer` in gdb |
| Layout is single window | use `M-x my/cpp-debug` (sets layout first) |
| Completions appear in `*gud*` | `my/gdb-no-completions` should be on `gdb-mode-hook` |

See `testBeforeIntegration/gdb_setup.org` for the full reference.
