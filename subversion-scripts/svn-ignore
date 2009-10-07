#!/usr/bin/env python
 
"""
Script to make it easier to add svn-ignore rules.
"""
 
import sys
import os
import subprocess
 
def svn_propget_svnignore(path):
    '''fetch the svn:ignore property of given path'''
    p = subprocess.Popen(['svn', 'propget', 'svn:ignore', path], stdout=subprocess.PIPE)
    p.wait()
    data = p.stdout.read().strip()
    return data
 
def svn_propset_svnignore(path, value):
    '''set the svn:ignore property of the given path'''
    p = subprocess.Popen(['svn', 'propset', 'svn:ignore', value, path])
    p.wait()
 
 
def main():
 
    if len(sys.argv) < 2:
        print 'Usage: %s filenames' % sys.argv[0]
        sys.exit()
 
    for path in sys.argv[1:]:
        print path
 
        dirpath, filename = os.path.split(path)
        svnignore_data = svn_propget_svnignore(dirpath)
 
        if filename not in svnignore_data:
            svnignore_data += '\n' + filename
            svn_propset_svnignore(dirpath, svnignore_data)
 
if __name__ == '__main__':
    main()
