# What
A simple script to build shadowsocks-libev static

# How

```bash
Current workspace is $HOME
Useage: sh build_static_ss.sh [--host=<host>] [--prefix=<path>]

Options:
     --host=<host>    the machine that you are building for
     --prefix=<path>  install architecture-independent files in $prefix
```

Download toolchain ,and set path env:

```bash
$ export PATH=/mnt/crosstoolchain/arm-linux-musleabi/bin:$PATH

$ which arm-linux-musleabi
/mnt/crosstoolchain/arm-linux-musleabi/bin


$ sh +x build_static_ss.sh --host=arm-linux-musleabi
```

[*] Tested with `aarch64-buildroot-linux-uclibc-gcc`

```bash
$ aarch64-buildroot-linux-uclibc-gcc -v

Using built-in specs.
COLLECT_GCC=/home/zhuzhihao/cross_compile/tools/aarch64--uclibc--stable-2018.11-1/bin/aarch64-buildroot-linux-uclibc-gcc.br_real
COLLECT_LTO_WRAPPER=/home/zhuzhihao/cross_compile/tools/aarch64--uclibc--stable-2018.11-1/bin/../libexec/gcc/aarch64-buildroot-linux-uclibc/7.3.0/lto-wrapper
Target: aarch64-buildroot-linux-uclibc
Configured with: ./configure --prefix=/opt/aarch64--uclibc--stable-2018.11-1 --sysconfdir=/opt/aarch64--uclibc--stable-2018.11-1/etc --enable-static --target=aarch64-buildroot-linux-uclibc --with-sysroot=/opt/aarch64--uclibc--stable-2018.11-1/aarch64-buildroot-linux-uclibc/sysroot --disable-__cxa_atexit --with-gnu-ld --disable-libssp --disable-multilib --with-gmp=/opt/aarch64--uclibc--stable-2018.11-1 --with-mpc=/opt/aarch64--uclibc--stable-2018.11-1 --with-mpfr=/opt/aarch64--uclibc--stable-2018.11-1 --with-pkgversion='Buildroot 2018.08.1-00003-g576b333' --with-bugurl=http://bugs.buildroot.net/ --disable-libquadmath --disable-libsanitizer --enable-tls --disable-libmudflap --enable-threads --without-isl --without-cloog --disable-decimal-float --with-abi=lp64 --with-cpu=cortex-a53 --enable-languages=c,c++ --with-build-time-tools=/opt/aarch64--uclibc--stable-2018.11-1/aarch64-buildroot-linux-uclibc/bin --enable-shared --disable-libgomp
Thread model: posix
gcc version 7.3.0 (Buildroot 2018.08.1-00003-g576b333)
```

[*] Tested with `aarch64-linux-musl-gcc`

```bash
$ aarch64-linux-musl-gcc -v

Using built-in specs.
COLLECT_GCC=aarch64-linux-musl-gcc
COLLECT_LTO_WRAPPER=/home/zhuzhihao/cross_compile/tools/aarch64-linux-musl-cross/bin/../libexec/gcc/aarch64-linux-musl/9.2.1/lto-wrapper
Target: aarch64-linux-musl
Configured with: ../src_gcc/configure --enable-languages=c,c++,fortran CC='gcc -static --static' CXX='g++ -static --static' FC='gfortran -static --static' CFLAGS='-g0 -O2 -fno-align-functions -fno-align-jumps -fno-align-loops -fno-align-labels' CXXFLAGS='-g0 -O2 -fno-align-functions -fno-align-jumps -fno-align-loops -fno-align-labels' FFLAGS='-g0 -O2 -fno-align-functions -fno-align-jumps -fno-align-loops -fno-align-labels' LDFLAGS='-s -static --static' --disable-bootstrap --disable-assembly --disable-werror --target=aarch64-linux-musl --prefix= --libdir=/lib --disable-multilib --with-sysroot=/aarch64-linux-musl --enable-tls --disable-libmudflap --disable-libsanitizer --disable-gnu-indirect-function --disable-libmpx --enable-libstdcxx-time=rt --enable-deterministic-archives --enable-libstdcxx-time --enable-libquadmath --enable-libquadmath-support --disable-decimal-float --with-build-sysroot=/kale/b_plain/build/local/aarch64-linux-musl/obj_sysroot AR_FOR_TARGET=/kale/b_plain/build/local/aarch64-linux-musl/obj_binutils/binutils/ar AS_FOR_TARGET=/kale/b_plain/build/local/aarch64-linux-musl/obj_binutils/gas/as-new LD_FOR_TARGET=/kale/b_plain/build/local/aarch64-linux-musl/obj_binutils/ld/ld-new NM_FOR_TARGET=/kale/b_plain/build/local/aarch64-linux-musl/obj_binutils/binutils/nm-new OBJCOPY_FOR_TARGET=/kale/b_plain/build/local/aarch64-linux-musl/obj_binutils/binutils/objcopy OBJDUMP_FOR_TARGET=/kale/b_plain/build/local/aarch64-linux-musl/obj_binutils/binutils/objdump RANLIB_FOR_TARGET=/kale/b_plain/build/local/aarch64-linux-musl/obj_binutils/binutils/ranlib READELF_FOR_TARGET=/kale/b_plain/build/local/aarch64-linux-musl/obj_binutils/binutils/readelf STRIP_FOR_TARGET=/kale/b_plain/build/local/aarch64-linux-musl/obj_binutils/binutils/strip-new --build=x86_64-pc-linux-musl --host=x86_64-pc-linux-musl
Thread model: posix
gcc version 9.2.1 20200229 (GCC)
```
