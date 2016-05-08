require 'mkmf'

dir_config('rdiscount')

HAVE_RANDOM = have_func('random')
HAVE_SRANDOM = have_func('srandom')
HAVE_RAND = have_func('rand')
HAVE_SRAND = have_func('srand')

def sized_int(size, types)
  types.find { |type| check_sizeof(type) == size } ||
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

# Post XCode 5.1 the command line tools on OS X treat unrecognised 
# command line options as errors and it's been seen that
# -multiply_definedsuppress can trickle from ruby build settings.
# Issue 115
if /darwin|mac os/.match RbConfig::CONFIG['host_os']
  $DLDFLAGS.gsub!("-multiply_definedsuppress", "")
end

if /mswin/.match RbConfig::CONFIG['host_os']
  $defs.push("-Dinline=__inline")
end

create_makefile('rdiscount')
