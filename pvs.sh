#!/usr/bin/env bash

# PVS-Studio Static Code Analysis
# https://www.viva64.com/en/m/0036/#ID0E6B

if [ $# -lt 1 ]; then
	echo "Usage: $0 gen[2|3l|3m|3b|4l]"
	exit 1
fi

rm -rf project.log pvs-studio-report-html project.tasks
pvs-studio-analyzer analyze -j8 -l ~/.config/PVS-Studio/PVS-Studio.lic -o project.log -f ./builders/cmake/output/${1}/MinSizeRel/STATIC/work/compile_commands.json
plog-converter -a GA:1,2 -t fullhtml -o pvs-studio-report-html project.log
plog-converter -a GA:1,2 -t tasklist -o project.tasks project.log

echo
echo "Open http://10.2.2.15:8889"

cd pvs-studio-report-html && python -m SimpleHTTPServer 8889

