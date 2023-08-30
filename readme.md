# VM - `V`irtual Machine

Language toolchain written in `V`:

- vasm: assembly like programming language
- vmc: vasm -> binary
- vmr: runs compiled vasm files

## Compile all:

Use `v build-all` to compile the toolchain, the you can use the executables in `vmc` and `vmr`

## VMC

Compiles each instruction to bytes, that can be later decoded using the [opcode table](./versions/0.1.0.md) provided in the repo.

```bash
./vmc [file].vasm
```

## VMR

Runs compiled `.vasm` files.

```bash
./vmr [file]
```