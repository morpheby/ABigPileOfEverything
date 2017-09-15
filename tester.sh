#!/usr/bin/env bash

if (( $# != 3 )); then
   echo "Syntax: $0 input output command"
fi

if [[ ! -e $1 ]]; then
   echo "Invalid file $1"
   exit 1;
fi

rm -f $2

if [[ x$CC == x ]]; then
   CC=clang
fi

killtree() {
    local parent=$1 child
    for child in $(ps -o ppid= -o pid= | awk "\$1==$parent {print \$2}"); do
        killtree $child
    done
    kill $parent
}


while true; do
   if [[ $1 -nt $2 ]]; then
      echo "Old proc pid=$proc_pid"
      if [[ x$proc_pid != x ]]; then
         echo "Killing $proc_pid"
         # eval "exec ${COPROC[1]}>&-"
         # eval "exec ${COPROC[0]}>&-"
         killtree $proc_pid
         # kill $proc_pid
      fi
      $CC $1 -o $2
      coproc \
         (
          eval "$3"
      )
      proc_pid=$COPROC_PID
      echo $proc_pid
   fi
   sleep 1
done

