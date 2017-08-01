#!/usr/bin/env bash
# Ref: https://github.com/prasmussen/gdrive

SharedFolder=$(gdrive list --query "name = 'SharedFolderToAnyoneWithLink' and mimeType = 'application/vnd.google-apps.folder'" | sed -n 2p | awk '{print $1}')
if [ "${SharedFolder}" = "" ]; then
	gdrive mkdir SharedFolderToAnyoneWithLink
	echo "Just created a 'SharedFolderToAnyoneWithLink' folder on your GDrive, please re-run again"
else
	gdrive upload -p "$SharedFolder" --share "$1"
fi
