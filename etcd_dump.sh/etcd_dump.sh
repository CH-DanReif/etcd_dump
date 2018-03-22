#!/bin/bash -ue

etcd_find_f ()
{
  etcdctl ls -r -p "${1:-/}" | grep -vE '/$'
}

etcd_pp ()
{
  local i="$1";
  local o;
  local olen;

  echo -n "${i}: "

  o="$(etcdctl get "$i")"
  olen="${o//[^$'\n']}"
  if [ "${#olen}" -ne 0 ] || grep -qE '[^ -~'$'\x80''-'$'\xfe'']' <<<"$o"; then
    echo "$(tput setaf 1)b64: $(tput sgr0)"$(base64 <<<"$o")
  else
    echo "$(tput setaf 2)${o}$(tput sgr0)"
  fi
}

if [ "x${1::1}" = "x-" ]; then
  echo "Syntax: $0 [prefix]" >&2
  exit 1
fi

for i in $(etcd_find_f "$1"); do
  etcd_pp "$i"
done
