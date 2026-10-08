#!/bin/bash

set -euo pipefail
diskusage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
free_memory=$(free -m | awk 'NR==2 {printf "%0.f\n", (($3/$2)*100)}')
problems=0
server=$(ps aux | grep "$1" | grep -v grep | grep -v "monitor.sh" || true)


if [ "$diskusage" -gt 80 ]; then
	echo "[WARN] Disk: $diskusage% used"
	problems=$((problems + 1))
else
	echo "[OK] Disk: $diskusage% used"
fi

if [ "$free_memory" -gt 80 ]; then
	echo "[WARN] Memory: $free_memory% used"
	problems=$((problems + 1))
else
	echo "[OK] Memory: $free_memory% used"
fi

if [ -z "$server" ]; then
	echo "[FAIL] $1 is NOT running"
	problems=$((problems+1))
else
	echo "[OK] $1 is running"
fi


logfile=$2
if [ ! -f "$logfile" ]; then
	echo "[WARN] Log file not found: $logfile"
	problems=$((problems + 1))
else
	errorcounts=$(grep -c "ERROR" "$2" || true)
	if [ "$errorcounts" -eq 0 ]; then
		echo "[OK] No errors in log"
	else
		echo "[WARN] $errorcounts errors found in log"
		problems=$((problems + 1))
	fi
fi

if [ "$problems" -gt 0 ]; then
	exit 1
else
	exit 0
fi
