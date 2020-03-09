#!/bin/bash
red="\033[0;31m"
green="\033[0;32m"
plain="\033[0m"

PCRE_VER="8.44"
PCRE_FILE="https://ftp.pcre.org/pub/pcre/pcre-$PCRE_VER.tar.gz"

MBEDTLS_VER=2.16.5
MBEDTLS_FILE="https://tls.mbed.org/download/mbedtls-$MBEDTLS_VER-gpl.tgz"


LIBSODIUM_VER=1.0.18
LIBSODIUM_FILE="https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VER.tar.gz"


LIBEV_VER=4.31
LIBEV_FILE="http://dist.schmorp.de/libev/libev-$LIBEV_VER.tar.gz"

LIBC_ARES_VER=1.14.0
LIBC_ARES_FILE="https://c-ares.haxx.se/download/c-ares-$LIBC_ARES_VER.tar.gz"


SHADOWSOCKS_LIBEV_VER=3.3.4
SHADOWSOCKS_LIBEV_FILE="https://github.com/shadowsocks/shadowsocks-libev"



set_cc_for_build='
trap "exitcode=\$?; (rm -f \$tmpfiles 2>/dev/null; rmdir \$tmp 2>/dev/null) && exit \$exitcode" 0 ;
trap "rm -f \$tmpfiles 2>/dev/null; rmdir \$tmp 2>/dev/null; exit 1" 1 2 13 15 ;
: ${TMPDIR=/tmp} ;
 { tmp=`(umask 077 && mktemp -d "$TMPDIR/cgXXXXXX") 2>/dev/null` && test -n "$tmp" && test -d "$tmp" ; } ||
 { test -n "$RANDOM" && tmp=$TMPDIR/cg$$-$RANDOM && (umask 077 && mkdir $tmp) ; } ||
 { tmp=$TMPDIR/cg-$$ && (umask 077 && mkdir $tmp) && echo "Warning: creating insecure temp directory" >&2 ; } ||
 { echo "$me: cannot create a temporary directory in $TMPDIR" >&2 ; exit 1 ; } ;
dummy=$tmp/dummy ;
tmpfiles="$dummy.c $dummy.o $dummy.rel $dummy" ;
CC_FOR_BUILD=$compiler ; set_cc_for_build= ;'

UNAME_SYSTEM=`(uname -s) 2>/dev/null`  || UNAME_SYSTEM=unknown
res=false

# as_fn_executable_p FILE
# -----------------------
# Test if FILE is an executable regular file.
as_fn_executable_p ()
{
  test -f "$1" && test -x "$1"
}
as_test_x='test -x'

test_file(){
    PATH_SEPARATOR=:
    local IFS=$PATH_SEPARATOR
    for path in $PATH;do
        if as_fn_executable_p $path/$1;then
            res=true;
            break
        else
            res=false
        fi
    done
}

prepare() {

#
# Detect the libc used by compiler
#
case "$UNAME_SYSTEM" in
Linux|GNU|GNU/*)
	# If the system lacks a compiler, then just pick glibc.
	# We could probably try harder.
	LIBC=gnu

	eval "$set_cc_for_build"
	cat <<-EOF > "$dummy.c"
	#include <features.h>
	#if defined(__UCLIBC__)
	LIBC=uclibc
	#elif defined(__dietlibc__)
	LIBC=dietlibc
	#else
	LIBC=gnu
	#endif
	EOF
	eval "`$CC_FOR_BUILD -E "$dummy.c" 2>/dev/null | grep '^LIBC' | sed 's, ,,g'`"

    {
        res=$($CC_FOR_BUILD -v 2>&1 | grep COLLECT_GCC | grep musl)
        [[ -n $res ]] && LIBC=musl
    }
    if test -n $LIBC;then
        echo -e "${green}$compiler with c library : $LIBC${plain}"
    else
        echo "${red}UNKNOW LIBC${plain}";
        exit 1;
    fi
	;;
esac



    rm -rf $cur_dir/build_src && mkdir $cur_dir/build_src
    rm -rf $prefix && mkdir $prefix
}



compile_pcre() {
    [ -d $prefix/pcre ] && return
    cd $cur_dir/build_src
    $proxychains wget --no-check-certificate $PCRE_FILE
    tar xvf pcre-$PCRE_VER.tar.gz
    cd pcre-$PCRE_VER
    CPPFLAGS="-DNEED_PRINTF" ./configure --prefix=$prefix/pcre --host=$host --enable-jit --enable-utf8 --enable-unicode-properties --disable-shared
    make -j2 && make install
}


compile_mbedtls() {
    [ -d $prefix/mbedtls ] && return

    cd $cur_dir/build_src
    $proxychains wget --no-check-certificate $MBEDTLS_FILE
    tar xvf mbedtls-$MBEDTLS_VER-gpl.tgz
    cd mbedtls-$MBEDTLS_VER
    prefix_reg=$(echo $prefix | sed "s/\//\\\\\//g")
    sed -i "s/DESTDIR=\/usr\/local/DESTDIR=$prefix_reg\/mbedtls/g" Makefile
    CC=$host-gcc AR=$host-ar LD=$host-ld make install -j2
}


compile_libsodium() {
    [ -d $prefix/libsodium ] && return

    cd $cur_dir/build_src
    $proxychains wget --no-check-certificate $LIBSODIUM_FILE
    tar xvf libsodium-$LIBSODIUM_VER.tar.gz
    cd libsodium-$LIBSODIUM_VER
    ./configure --prefix=$prefix/libsodium --host=$host --disable-ssp --disable-shared
    CC=$host-gcc AR=$host-ar LD=$host-ld make -j2 && CC=$host-gcc AR=$host-ar LD=$host-ld make install
}


compile_libev() {
    [ -d $prefix/libev ] && return

    cd $cur_dir/build_src
    $proxychains wget --no-check-certificate $LIBEV_FILE
    tar xvf libev-$LIBEV_VER.tar.gz
    cd libev-$LIBEV_VER
    ./configure --prefix=$prefix/libev --host=$host --disable-shared
    CC=$host-gcc AR=$host-ar LD=$host-ld make -j2 && CC=$host-gcc AR=$host-ar LD=$host-ld make install
}

compile_libc_ares() {
    [ -d $prefix/libc-ares ] && return

    cd $cur_dir/build_src
    proxychains wget --no-check-certificate $LIBC_ARES_FILE
    tar xvf c-ares-$LIBC_ARES_VER.tar.gz
    cd c-ares-$LIBC_ARES_VER
    ./configure --prefix=$prefix/libc-ares --host=$host --disable-shared
    CC=$host-gcc AR=$host-ar LD=$host-ld make -j2 && CC=$host-gcc AR=$host-ar LD=$host-ld make install
}


compile_shadowsocks_libev() {
    [ -f $prefix/shadowsocks-libev/bin/ss-local ] && return

    cd $cur_dir/build_src
    $proxychains git clone --branch v$SHADOWSOCKS_LIBEV_VER --single-branch --depth 1 $SHADOWSOCKS_LIBEV_FILE
    cd shadowsocks-libev
    $proxychains git submodule update --init --recursive
    ./autogen.sh
    LDFLAGS="--static -L$prefix/libc-ares/lib -L$prefix/libev/lib" CFLAGS="-I$prefix/libc-ares/include -I$prefix/libev/include" ./configure --prefix=$prefix/shadowsocks-libev --host=$host --disable-ssp --disable-documentation --with-mbedtls=$prefix/mbedtls --with-pcre=$prefix/pcre --with-sodium=$prefix/libsodium
    CC=$host-gcc AR=$host-ar LD=$host-ld make -j2 && CC=$host-gcc AR=$host-ar LD=$host-ld make install
}

clean() {
    cd $cur_dir
    rm -rf $cur_dir/build_src
}




main(){

    cur_dir="$(cd "$(dirname "$0")" && pwd)"
    requir_bin="sed cut find make git"

    for prog in $requir_bin;do
        test_file $prog
    if [ $res = "true"  ];then
        echo "Found $prog";
    else
        echo Cannot found $prog && exit 1;
    fi

done

: ${prefix=$cur_dir/build_library} ;

while [ ! -z $1 ]; do
    case $1 in
        -h | --help)
            echo "Useage: sh $0 [--host=<host>] [--prefix=<path>]"
            echo ""
            echo "Options:"
            echo "     --host=<host>    the machine that you are building for"
            echo "     --prefix=<path>  install architecture-independent files in $prefix"
            exit 0;;
        --host )
            shift
            host=$1;;
        --host=* )
            arr=$(echo $1 | cut -f2 -d '=')
            host=$arr

            if [[ -n $host ]];then
                compiler=$host-gcc
            else
                echo -e "${red}You must special the host which you are build for${plain}"
            exit 1;
            fi
            ;;
        --prefix)
            shift
            prefix=$1
            echo "You set prefix: $prefix";;
        --prefix=*)
            arr=$(echo $1 | cut -f2 -d '=')
            prefix=$arr
            echo "You set prefix: $prefix"
            ;;
    esac
    shift
done



echo ""
echo -e "binaries will be installed in ${green}${prefix}${plain}"
echo ""

# Found cross_compiler
{
    test_file $compiler
    if [[ $res = "true"  ]];then
        echo "Found $compiler"
    else
        echo -e "${red}Error:${plain} not found cross compiler ${green}${compiler}${plain}"
        exit 1;
    fi
}

prepare
compile_pcre
compile_mbedtls
compile_libsodium
compile_libev
compile_libc_ares
compile_shadowsocks_libev
clean
}

main $@
