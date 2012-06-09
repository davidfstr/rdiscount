require 'mkmf'

dir_config('rdiscount')

HAVE_RANDOM = have_func('random')
HAVE_SRANDOM = have_func('srandom')
HAVE_RAND = have_func('rand')
HAVE_SRAND = have_func('srand')

DWORD = "unsigned long"
WORD =  "unsigned short"
BYTE = "unsigned char"

$defs.push("-DDWORD='#{DWORD}'")
$defs.push("-DWORD='#{WORD}'")
$defs.push("-DBYTE='#{BYTE}'")

create_makefile('rdiscount')
