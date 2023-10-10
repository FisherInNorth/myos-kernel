# oskernel2023-x

## 依赖

+ `qemu-system-riscv64`
+ RISC-V GCC 编译链: [riscv-gnu-toolchain](https://github.com/riscv/riscv-gnu-toolchain.git)

## <a id="title_qemu">在 qemu-system-riscv64 模拟器上运行</a>

您只需要执行：

```bash
make all
make qemu
```

Ps: 按 `Ctrl + A` 然后 `X` 退出 `qemu`。     





基于XV6-RISCV On K210 、xv6-riscv 、rv6

移植开发板所需的启动配置文件在makecv1811目录下。

比赛代码描述.md文档在doc目录下，pdf见系统文档。

