#!/usr/bin/env bash
# - Ref: https://github.com/prasmussen/gdrive
# - TUTORIAL: How to get rid of 403 Errors #426
#   - https://github.com/gdrive-org/gdrive/issues/426

SharedFolder=$(gdrive list --query "name = 'SharedFolderToAnyoneWithLink2020' and mimeType = 'application/vnd.google-apps.folder'" | sed -n 2p | awk '{print $1}')
if [ "${SharedFolder}" = "" ]; then
	gdrive mkdir SharedFolderToAnyoneWithLink2020
	echo "Just created a 'SharedFolderToAnyoneWithLink2020' folder on your GDrive, please re-run again"
else
	gdrive upload -p "$SharedFolder" --share "$1"
fi
