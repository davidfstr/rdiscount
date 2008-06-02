require 'mkmf'

dir_config('rdiscount')

HAVE_RANDOM = have_func('random')
HAVE_SRANDOM = have_func('srandom')
HAVE_FUNOPEN = have_func('funopen')
HAVE_FOPENCOOKIE = have_func('fopencookie')

unless HAVE_FUNOPEN || HAVE_FOPENCOOKIE
  fail "No funopen or fopencookie support available."
end

create_makefile('rdiscount')
