require 'mkmf'

dir_config('rdiscount')

HAVE_RANDOM = have_func('random')
HAVE_SRANDOM = have_func('srandom')

create_makefile('rdiscount')
