#!/usr/bin/env python
#
# CDF.xml parsing script
#
# Author: Ramax Lo <ramax.lo@vivotek.com>
#
#

import os, sys
import xml.dom.minidom

params = []

def help():
	print 'Usage: cdfparser.xml <CDF.xml>'

def is_element(e):
	return e.nodeType == xml.dom.Node.ELEMENT_NODE

def is_text(e):
	return e.nodeType == xml.dom.Node.TEXT_NODE

def has_direct_element(element, name):
	for e in element.childNodes:
		if is_element(e) and e.tagName == name:
			return True

	return False

def get_direct_element(element, name):
	for e in element.childNodes:
		if is_element(e) and e.tagName == name:
			return e

	return None

def has_alias(element):
	return has_direct_element(element, 'aliasxpath')

def has_value(element):
	return has_direct_element(element, 'value')

def get_text(element):
	textnode = element.childNodes[0]
	if is_text(textnode):
		return textnode.nodeValue

	return None

def get_seclevel(element):
	tmp = element

	while not has_direct_element(tmp, 'seclevel'):
		tmp = tmp.parentNode

	if tmp.tagName == 'root':
		return 'n/a'

	seclevel = get_direct_element(tmp, 'seclevel')

	return get_text(seclevel)

def get_alias(element):
	alias = get_direct_element(element, 'aliasxpath')

	return get_text(alias)

def get_check(element):
	check = get_direct_element(element, 'check')

	if check:
		return get_text(check)

	return 'n/a'

def store_path(path, element):
	seclevel = get_seclevel(element)
	check = get_check(element)

	tmp = {}
	tmp['path'] = path
	tmp['seclevel'] = seclevel
	tmp['check'] = check

	params.append(tmp)

def store_alias_path(path, element):
	seclevel = get_seclevel(element)
	aliasxpath = get_alias(element)

	tmp = {}
	tmp['path'] = path
	tmp['aliasxpath'] = aliasxpath

	params.append(tmp)

def do_parse(path, element):
	if has_value(element):
		tmp = path + element.tagName

		store_path(tmp, element)
	elif has_alias(element):
		tmp = path + element.tagName

		store_alias_path(tmp, element)
	else:
		for e in element.childNodes:
			if is_element(e):
				tmp = path + '%s_' % element.tagName
				do_parse(tmp, e)

def parse(dom):
	root = dom.getElementsByTagName('root')[0]

	for e in root.childNodes:
		if is_element(e):
			path = ''
			do_parse(path, e)

def param_cmp(x, y):
	if x['path'] > y['path']:
		return 1
	elif x['path'] < y['path']:
		return -1
	else:
		return 0

def get_origin(alias):
	for p in params:
		if not p.has_key('aliasxpath') and p['path'] == alias:
			return p

	return None

def dump_params():
	params.sort(cmp = param_cmp)

	for p in params:
		if p.has_key('aliasxpath'):
			origin = get_origin(p['aliasxpath'])

			if origin:
				print '%-5s %s %s' % (origin['seclevel'], p['path'], origin['check'])
			else:
				print '%-5s %s %s' % ('alias', p['path'], 'alias')
		else:
			print '%-5s %s %s' % (p['seclevel'], p['path'], p['check'])

if __name__ == '__main__':
	if len(sys.argv) < 2:
		help()
		sys.exit(1)

	infile = sys.argv[1]
	dom = xml.dom.minidom.parse(infile)

	parse(dom)
	dump_params()
