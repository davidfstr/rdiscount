
/* rdiscount extension configuration */

#undef USE_AMALLOC

#define TABSTOP 4

#define COINTOSS() (random()&1)

#define HAVE_SRANDOM 1

#define INITRNG(x) srandom((unsigned int)x)

#define HAVE_RANDOM 1
