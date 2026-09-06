# C++ GDB Debug — Test Cheat Sheet (demo `~/debug_cpp`)

Manual checklist to run after the automated suite
(`bash test/test_gdb_workflow.sh`) passes.

## 0. Deps

```sh
gdb --version
rr --version
cmake --version
emacs --version
```

## 1. Build (in place)

```sh
cd ~/debug_cpp
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug && cmake --build build
file build/debug_demo   # expect: with debug_info
```

If switching from a Release cache: `rm -rf build` first.

## 2. CLI sanity (no Emacs)

```sh
gdb -batch ./build/debug_demo \
  -ex 'break demonstrate_smart_ptr' -ex run \
  -ex 'next' -ex 'print *res' -ex 'print *res2' \
  -ex continue -ex quit
# expect: id_ = 42, id_ = 99

gdb -batch ./build/debug_demo \
  -ex 'break main' -ex run \
  -ex 'print std::get<0>(v)' -ex 'print safe_null' \
  -ex continue -ex quit
# expect: "variant demo", safe_null nullopt (no crash)
```

## 3. Emacs flow

```text
emacs ~/debug_cpp/src/main.cpp
M-x compile        # dir-locals: cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug && cmake --build build
;; set (setq gdb-many-windows t) BEFORE launching
M-x gdb RET gdb -i=mi --args ~/debug_cpp/build/debug_demo
```

| Key    | Command   | Key    | Command         |
|--------|-----------|--------|-----------------|
| `C-c b`| break     | `C-c n`| next (over)     |
| `C-c s`| step (in) | `C-c c`| continue        |
| `C-c f`| finish    | `C-c r`| run             |
| `C-c p`| print     | `C-c q`| quit            |
| `C-c R`| record    | `C-c N`| reverse-next    |
| `C-c S`| reverse-step | `C-c C`| reverse-continue |

Console check (the old bug): typing `r`, `run`, `print res`
in `*gud*` must insert text, never fire commands.

Deref recipes in the gud buffer:

```text
(gdb) p *res
(gdb) p *res2
(gdb) p safe_null
(gdb) p std::get<0>(v)
(gdb) p std::get<std::string>(v)
```

## 4. `record` (best-effort)

```text
(gdb) record
(gdb) reverse-next (rn)
(gdb) reverse-step (rs)
(gdb) reverse-continue (rc)
(gdb) record stop
```

May fail on some syscalls/AVX/aarch64 — fall back to forward debug.

## 5. `rr` (x86_64-focused)

```sh
rr record ./build/debug_demo
rr replay
```

```text
M-x gdb RET gdb -i=mi rr replay
```

On aarch64 a failure is architecture (suspect #1), not config.

## 6. If red

| Symptom | Fix |
|---------|-----|
| No symbols | `rm -rf build`, rebuild Debug |
| Pretty-print missing | `info pretty-printer` in gdb |
| Layout is single window | set `gdb-many-windows t` before `M-x gdb` |
| Prompt asks for command | launch as `gdb -i=mi --args ./build/<binary>` |
| `C-c r` vs `C-c R` confusion | lowercase = run, uppercase = record (`which-key` to confirm) |

See `testBeforeIntegration/gdb_setup.org` for the full reference.
