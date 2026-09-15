# playground
This includes the code for chemical playground

### Requirements

You must have docker installed on your machine, This project will try to use docker from the command line, it creates containers of chemical to run user code

### Limitations

These limitations will be addressed in upcoming chemical releases

1 - on windows, you must use mode `debug_complete`

2 - on linux, you must use mode `debug` or `release`

3 - use `--no-cache` when compiling the lab file

For windows:
```
./chemical.exe build.lab --mode debug_complete --no-cache
```

For linux:
```
./chemical build.lab --mode debug --no-cache
```

### Building & Running (scripts)

Convenience scripts live in `scripts/`. Each has a bash and a PowerShell mirror. They auto-locate the Chemical compiler under the repo root (`cmake-build-debug/` or `build/`) and run with the repo root as working directory so dev asset paths (`lang/compiled/playground/src/assets/...`) resolve.

Build the server binary:
```
./scripts/build.sh            # or: pwsh scripts/build.ps1
```

Run the server (builds first unless `--no-build`):
```
./scripts/serve.sh            # or: pwsh scripts/serve.ps1
./scripts/serve.sh --no-build
```
The app listens on port 8080 by default.

### Tests

Tests live in `tests/` and are annotated with `@test`. They are a separate build flavor: `chemical.mod` compiles `src/` always, `src/app/` (the real server main) only in app mode, and `tests/` only when building with `--test`. The test binary ships its own `tests/main.ch` that dispatches to the shared `test_runner`.

Build and run the unit/integration suite (validation, versions, docker helpers, SSR pages, live endpoints over loopback):
```
./scripts/test.sh             # or: pwsh scripts/test.ps1
./scripts/test.sh --test-names "test_valid_simple_name"   # run by name
./scripts/test.sh --no-build                              # reuse previous binary
```

Boot the real server and probe every route over HTTP (always exits cleanly):
```
./scripts/playground-build-test.sh              # or: pwsh scripts/playground-build-test.ps1
PLAYGROUND_TEST_PORT=8123 ./scripts/playground-build-test.sh
```

### Project layout

```
chemical.mod          # module definition; app/test source switching lives here
src/                  # shared code (pages, components, validation, docker, versions)
app/main.ch           # server entry point — compiled only when NOT building with --test
tests/                # @test sources + tests/main.ch — compiled only with --test
scripts/              # build/test/serve scripts (bash + PowerShell)
```