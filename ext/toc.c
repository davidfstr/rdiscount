/*
 * toc -- spit out a table of contents based on header blocks
 *
 * Copyright (C) 2008 Jjgod Jiang, David L Parsons
 * portions Copyright (C) 2011 Stefano D'Angelo
 * The redistribution terms are provided in the COPYRIGHT file that must
 * be distributed with this source code.
 */
#include "config.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#include "cstring.h"
#include "markdown.h"
#include "amalloc.h"

static int Csputc_mkd_sta_function_t(const int n, const void* iot) {
  Csputc(n, iot);
}

/* write an header index
 */
int
mkd_toc(Document *p, char **doc)
{
    Paragraph *tp, *srcp;
    int last_hnumber = 0;
    Cstring res;
    int size;
    int first = 1;
    extern void Csreparse(Cstring *, char *, int, mkd_flag_t);
    
    
    if ( !(doc && p && p->ctx) ) return -1;

    *doc = 0;
    
    if ( ! is_flag_set(p->ctx->flags, MKD_TOC) ) return 0;

    CREATE(res);
    RESERVE(res, 100);

    for ( tp = p->code; tp ; tp = tp->next ) {
	if ( tp->typ == SOURCE ) {
	    for ( srcp = tp->down; srcp; srcp = srcp->next ) {
		if ( (srcp->typ == HDR) && srcp->text ) {
	    
		    while ( last_hnumber > srcp->hnumber ) {
			if ( (last_hnumber - srcp->hnumber) > 1 )
				Csprintf(&res, "\n");
			Csprintf(&res, "</li>\n%*s</ul>\n%*s",
				 last_hnumber-1, "", last_hnumber-1, "");
			--last_hnumber;
		    }

		    if ( last_hnumber == srcp->hnumber )
			Csprintf(&res, "</li>\n");
		    else if ( (srcp->hnumber > last_hnumber) && !first )
			Csprintf(&res, "\n");

		    while ( srcp->hnumber > last_hnumber ) {
			Csprintf(&res, "%*s<ul>\n", last_hnumber, "");
			if ( (srcp->hnumber - last_hnumber) > 1 )
			    Csprintf(&res, "%*s<li>\n", last_hnumber+1, "");
			++last_hnumber;
		    }
		    Csprintf(&res, "%*s<li><a href=\"#", srcp->hnumber, "");
		    mkd_string_to_anchor(T(srcp->text->text),
					 S(srcp->text->text),
					 Csputc_mkd_sta_function_t,
					 &res,1,p->ctx);
		    Csprintf(&res, "\">");
		    Csreparse(&res, T(srcp->text->text),
				    S(srcp->text->text), IS_LABEL);
		    Csprintf(&res, "</a>");

		    first = 0;
		}
	    }
        }
    }

    while ( last_hnumber > 0 ) {
	--last_hnumber;
	Csprintf(&res, "</li>\n%*s</ul>\n%*s",
		 last_hnumber, "", last_hnumber, "");
    }

    if ( (size = S(res)) > 0 ) {
	/* null-terminate & strdup into a free()able memory chunk
	 */
	EXPAND(res) = 0;
	*doc = strdup(T(res));
    }
    DELETE(res);
    return size;
}


/* write an header index
 */
int
mkd_generatetoc(Document *p, FILE *out)
{
    char *buf = 0;
    int sz = mkd_toc(p, &buf);
    int ret = EOF;

    if ( sz > 0 )
	ret = fwrite(buf, 1, sz, out);

    if ( buf ) free(buf);

    return (ret == sz) ? ret : EOF;
}
