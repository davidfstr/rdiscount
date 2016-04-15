#include "config.h"

char markdown_version[] = VERSION
#if 4 != 4
		" TAB=4"
#endif
#if USE_AMALLOC
		" DEBUG"
#endif
#if WITH_LATEX
		" LATEX"
#endif
		;
