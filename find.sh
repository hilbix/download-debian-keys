#!/bin/bash

STDOUT() { local e=$?; printf '%q' "$1"; [ 1 = $# ] || printf ' %q' "${@:2}"; printf '\n'; return $e; }
STDERR() { local e=$?; STDOUT "$@"; return $e; }
OOPS() { for a; do echo "OOPS: $a"; done >&2; exit 23; }
x() { STDERR "exec:" "$@"; "$@"; STDERR "rc=$?:" "$@"; }
o() { "$@" || OOPS "exec $?: $*"; }

if [ .-D = ".$1" ]
then
	shift
	quiet() { STDERR DEBUG; x "$@"; STDERR DEBUG; }
else
	quiet() { "$@" >/dev/null 2>&1; }
fi

[ 1 = "$#" ] || OOPS "Usage: $0 directory"

DIR="${1%/}"
VER="${DIR##*/}"
DIR="$(readlink -e "$DIR")" && [ -d "$DIR" ] || OOPS "not a directory: $1"

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
local A="$(readlink -e "$1")" && [ -f "$A" ] || OOPS "internal error: missing sig $1"

quiet gpg --no-default-keyring "${@:2}" --verify "$1"
}

echo "trying to locate correct keys for $VER in $HERE"

locate()
{
DST=
for a
do
	[ -d "$a" ] || continue

	ARGS=()
	for b in "$PWD/$a"/*.gpg
	do
		[ -s "$b" ] && ARGS+=(--keyring "$b")
	done
	[ 0 != "${#ARGS[@]}" ] || OOPS "no keys found in directory $PWD/$a"
	
	ok=false
	for b in "${LIST[@]}"
	do
		verify "$b" "${ARGS[@]}" && ok=: || continue 2
	done
	$ok || OOPS "internal error, empty list ${LIST[*]}"

	printf 'found %q verifies %q\n' "$PWD/$a" "$DIR"
	DST="$a"
done
[ -n "$DST" ]
}

if	locate copy/* devuan
then
	printf '\ntry: ln -Ts %q %q\n\n' "$DST" "$PWD/$VER"
	exit 0
fi

OOPS "sorry, no matching key directory found"

