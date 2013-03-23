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

open(File.join(File.dirname(__FILE__), "ruby-config.h"), "wb") do |f|
  f.write <<-EOF
// These data types may be already defined if building on Windows (using MinGW)
#ifndef DWORD
  #define DWORD #{DWORD}
#endif
#ifndef WORD
  #define WORD #{WORD}
#endif
#ifndef BYTE
  #define BYTE #{BYTE}
#endif
  EOF
end

$defs.push("-DVERSION=\\\"#{VERSION}\\\"")

create_makefile('rdiscount')
