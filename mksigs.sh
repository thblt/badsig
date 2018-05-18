#!/bin/sh

GPG=gpg
OUTDIR=signatures

TIMEWARP="--faked-system-time 1262305000"

K_OK="-u key@badsig.example.com"
K_EXP="-u expired@badsig.example.com $TIMEWARP"

S_OK=""
S_EXP="--default-sig-expire 1d $TIMEWARP"

function sign() {
    # Sign a message and write the result to $1, passing remaining arguments to GnuPG
    file=$1
    shift
    echo echo "Whatever" | $GPG --clearsign $@ > $OUTDIR/$file.txt
}

function turn_bad() {
    sed -i "s/Whatever/However/" $OUTDIR/$1.txt
}

 Valid_KOK_SOK   $K_OK  $S_OK
sign Valid_KOK_SEXP  $K_OK  $S_EXP
sign Valid_KEXP_SOK  $K_EXP $S_OK
sign Valid_KEXP_SEXP $K_EXP $S_EXP

sign Invalid_kok_sok   $K_OK  $S_OK
sign Invalid_KOK_SEXP  $K_OK  $S_EXP
sign Invalid_KEXP_SOK  $K_EXP $S_OK
sign Invalid_KEXP_SEXP $K_EXP $S_EXP
turn_bad Invalid_kok_sok
turn_bad Invalid_KOK_SEXP
turn_bad Invalid_KEXP_SOK
turn_bad Invalid_KEXP_SEXP

echo "Unsigned!" > $OUTDIR/Unsigned.txt

sign Corrupted $K_OK
sed -i "s/Z/z/" $OUTDIR/Corrupted.txt
