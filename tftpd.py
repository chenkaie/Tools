#!/bin/sh
# sudo apt-get install python-tftpy

echo ================================
echo "TFTP root path: $HOME/tmp"
echo ================================
sudo /usr/share/doc/python-tftpy/examples/tftpy_server.py -p 69 -r $HOME/tmp/
