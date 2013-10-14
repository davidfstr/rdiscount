/*
 * rdiscount extension discount configuration
 */
#ifndef __MARKDOWN_D
#define __MARKDOWN_D 1

/* tabs are four spaces */
#define TABSTOP 4

/* enable fenced code blocks */
#define WITH_FENCED_CODE 1

/* include - and _ as acceptable characters in HTML tag names */
#define WITH_GITHUB_TAGS 1

/* enable discount and PHP Markdown Extra definition lists */
#define USE_EXTRA_DL 1
#define USE_DISCOUNT_DL 1

/* these are setup by extconf.rb */
#if HAVE_RANDOM
#define COINTOSS() (random()&1)
#elif HAVE_RAND
#define COINTOSS() (rand()&1)
#endif

#if HAVE_SRANDOM
#define INITRNG(x) srandom((unsigned int)x)
#elif HAVE_SRAND
#define INITRNG(x) srand((unsigned int)x)
#endif

#include "ruby-config.h"

#endif/* __MARKDOWN_D */
