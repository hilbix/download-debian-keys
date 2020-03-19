#!/bin/bash

STDOUT() { local e=$?; printf '%q' "$1"; [ 1 = $# ] || printf ' %q' "${@:2}"; printf '\n'; return $e; }
STDERR() { local e=$?; STDOUT "$@"; return $e; }
OOPS() { for a; do echo "OOPS: $a"; done >&2; exit 23; }
x() { STDERR "exec:" "$@"; "$@"; STDERR "rc=$?:" "$@"; }
o() { "$@" || OOPS "exec $?: $*"; }
quiet() { "$@" >/dev/null 2>&1; }

[ 2 = "$#" ] || OOPS "Usage: $0 keyfile directory"

KEY="$1"
DIR="$2"

VER="${2##*/}"
DIR="$(readlink -e "$DIR")" && [ -d "$DIR" ] || OOPS "not a directory: $2"

LIST=()
for a in "$DIR"/*.sign
do
	[ -f "$a" ] || OOPS "not a file: $a"
	LIST+=("$a")
done

HERE="$(dirname -- "$0")"
[ . = "$HERE" ] && HERE="$(readlink -e "$HERE")"
TO="$(dirname -- "$HERE")"
TO="$(readlink -e -- "$TO")"
o cd "$HERE"

verify()
{
local A="$(readlink -e "$1")" && [ -f "$A" ] || OOPS "internal error: missing key $1"
local B="$(readlink -e "$2")" && [ -f "$B" ] || OOPS "internal error: missing sig $2"
quiet gpg --no-default-keyring --keyring "$A" --verify "$2"
}

if	[ -f "$VER/$KEY" ]
then
	for a in "${LIST[@]}"
	do
		verify "$VER/$KEY" "$a" ||
		OOPS "bug: $PWD/$VER/$KEY does not verify "$a", something is completely wrong"
	done
	printf '\ntry: ln -Ts %s %s\n\n' "${HERE##*/}/$VER" "$TO/.$VER"
	exit 0
fi

echo "trying to locate correct $HERE/$VER/$KEY"

locate()
{
DST=
for a
do
	[ -f "$a" ] || continue
	ok=false
	for b in "${LIST[@]}"
	do
		verify "$PWD/$a" "$b" && ok=: || continue 2
	done
	$ok || OOPS "internal error, empty list ${LIST[*]}"

	echo "found $PWD/$a verifies $b"
	DST="$a"
done
[ -n "$DST" ]
}

if	locate copy/*/"$KEY"
then
	printf '\ntry: ln -Ts %q %q\n\n' "${DST%/*}" "$PWD/$VER"
	exit 0
fi

if	locate copy/*/*.pgp
then
	printf '\ntry: mkdir %q && ln -Ts --relative %q %q\n\n' "$PWD/$VER" "$PWD/$DST" "$PWD/$VER/$KEY"
	exit 0
fi

OOPS "sorry, no matching key found"
