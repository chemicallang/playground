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