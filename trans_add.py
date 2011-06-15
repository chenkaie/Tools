#!/usr/bin/python
#
# The translation string merging script
#
# Author: Ramax Lo <ramax.lo@vivotek.com>
#
# The script reads translation strings from an Excel file and merges
# them with the existing XML file (translator.xml), while maintaining 
# ascending alphabet order. The merged result is written to output.xml,
# if not specified in command line. An option is added to specify which
# sheet in the Excel file is used for merging.
#
# Note to run the script, a Python module 'xlrd' needs to be installed
# for reading data from Excel files.
# 

import sys
import getopt
import xml.dom.minidom

sys.path.append('/home/ramax/python/lib/python2.6/site-packages')
import xlrd

lang_map = {
	'en'   : 1,
	'zh-tw': 3,
	'de'   : 4,
	'es'   : 5,
	'fr'   : 6,
	'it'   : 7,
	'jp'   : 8,
	'po'   : 9,
	'zh-cn': 10,
}

outfile = 'output.xml'
sheet_number = 0

def help_msg():
	print "Usage: trans_add.py [-n sheet number] <Excel file> <input xml> [output xml]"

def lang_to_idx(lang):
	return lang_map[lang]

def get_str(array, lang):
	return array[lang_to_idx(lang)].value

def get_elements(element):
	tmp = []

	for node in element.childNodes:
		if node.nodeType == xml.dom.Node.ELEMENT_NODE:
			tmp.append(node)
	return tmp

def insert_str(dom, lang, tag, string):
	elements = get_elements(lang)
	ref_element = None

	for element in elements:
		if element.tagName > tag:
			ref_element = element
			break
		elif element.tagName == tag:
			# The tag already exists
			return
		else:
			pass

	tmp = dom.createElement(tag)
	text = dom.createTextNode(string)
	newline = dom.createTextNode(u'\n')
	tmp.appendChild(text)
	lang.insertBefore(tmp, ref_element)
	lang.insertBefore(newline, ref_element)

###################
#      START      #
###################

try:
	opts, args = getopt.getopt(sys.argv[1:], 'n:')
except getopt.GetoptError, e:
	print str(e)
	help_msg()
	sys.exit(1)
	
for opt, val in opts:
	if opt == '-n':
		sheet_number = int(val)

if len(args) < 2:
	help_msg()
	sys.exit(1)

excel = args[0]
infile = args[1]
if len(args) > 2:
	outfile = args[2]

print "Write output to %s" % outfile
book = xlrd.open_workbook(excel)
sheet = book.sheet_by_index(sheet_number)

dom = xml.dom.minidom.parse(infile)
langs = dom.getElementsByTagName('lang')
if len(langs) != 9:
	print "There must be 9 'lang' elements"
	sys.exit(1)

for i in range(1, sheet.nrows):
	row = sheet.row(i)

	tag = row[0].value
	if tag == '':
		continue
	en_str = get_str(row, 'en')
	de_str = get_str(row, 'de')
	es_str = get_str(row, 'es')
	fr_str = get_str(row, 'fr')
	it_str = get_str(row, 'it')
	jp_str = get_str(row, 'jp')
	po_str = get_str(row, 'po')
	zh_cn_str = get_str(row, 'zh-cn')
	zh_tw_str = get_str(row, 'zh-tw')

	insert_str(dom, langs[0], tag, en_str)
	insert_str(dom, langs[1], tag, de_str)
	insert_str(dom, langs[2], tag, es_str)
	insert_str(dom, langs[3], tag, fr_str)
	insert_str(dom, langs[4], tag, it_str)
	insert_str(dom, langs[5], tag, jp_str)
	insert_str(dom, langs[6], tag, po_str)
	insert_str(dom, langs[7], tag, zh_cn_str)
	insert_str(dom, langs[8], tag, zh_tw_str)

out = open(outfile, 'w')
outxml = dom.toxml('UTF-8')
out.write(outxml)
out.close()
