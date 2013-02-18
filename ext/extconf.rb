require 'mkmf'

dir_config('rdiscount')

HAVE_RANDOM = have_func('random')
HAVE_SRANDOM = have_func('srandom')
HAVE_RAND = have_func('rand')
HAVE_SRAND = have_func('srand')

def sized_int(size, types)
  types.find { |type| check_sizeof(type) == 4 } ||
    abort("no int with size #{size}")
end

DWORD = sized_int(4, ["unsigned long", "unsigned int"])
WORD =  sized_int(2, ["unsigned int", "unsigned short"])
BYTE = "unsigned char"
VERSION = IO.read('VERSION').strip

$defs.push("-DDWORD='#{DWORD}'")
$defs.push("-DWORD='#{WORD}'")
$defs.push("-DBYTE='#{BYTE}'")
$defs.push("-DVERSION=\\\"#{VERSION}\\\"")

create_makefile('rdiscount')
