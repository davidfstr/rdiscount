#include <stdio.h>
#include <locale.h>
#include "ruby.h"
#include "mkdio.h"

typedef struct {
    char *accessor_name;
    int flag;
} AccessorFlagPair;

/* 
 * Maps accessor names on the RDiscount object to Discount flags.
 * 
 * The following flags are handled specially:
 * - MKD_TABSTOP: Always set.
 * - MKD_NOHEADER: Always set.
 * - MKD_DLEXTRA: Always set. (For compatibility with RDiscount 2.1.8 and earlier.)
 * - MKD_FENCEDCODE: Always set. (For compatibility with RDiscount 2.1.8 and earlier.)
 * - MKD_GITHUBTAGS: Always set. (For compatibility with RDiscount 2.1.8 and earlier.)
 * - MKD_NOPANTS: Set unless the "smart" accessor returns true.
 * 
 * See rb_rdiscount__get_flags() for the detailed implementation.
 */
static AccessorFlagPair ACCESSOR_2_FLAG[] = {
    { "filter_html", MKD_NOHTML },
    { "footnotes", MKD_EXTRA_FOOTNOTE },
    { "generate_toc", MKD_TOC },
    { "no_image", MKD_NOIMAGE },
    { "no_links", MKD_NOLINKS },
    { "no_tables", MKD_NOTABLES },
    { "strict", MKD_STRICT },
    { "autolink", MKD_AUTOLINK },
    { "safelink", MKD_SAFELINK },
    { "no_pseudo_protocols", MKD_NO_EXT },
    { "no_superscript", MKD_NOSUPERSCRIPT },
    { "no_strikethrough", MKD_NOSTRIKETHROUGH },
    { NULL, 0 }     /* sentinel */
};

static VALUE rb_cRDiscount;

int rb_rdiscount__get_flags(VALUE ruby_obj)
{
    AccessorFlagPair *entry;
    
    /* compile flags */
    int flags = MKD_TABSTOP | MKD_NOHEADER | MKD_DLEXTRA | MKD_FENCEDCODE | MKD_GITHUBTAGS;
    
    /* The "smart" accessor turns OFF the MKD_NOPANTS flag. */
    if ( rb_funcall(ruby_obj, rb_intern("smart"), 0) != Qtrue ) {
        flags = flags | MKD_NOPANTS;
    }
    
    /* Handle standard flags declared in ACCESSOR_2_FLAG */
    for ( entry = ACCESSOR_2_FLAG; entry->accessor_name; entry++ ) {
        if ( rb_funcall(ruby_obj, rb_intern(entry->accessor_name), 0) == Qtrue ) {
            flags = flags | entry->flag;
        }
    }
    
    return flags;
}

static VALUE
rb_rdiscount_to_html(int argc, VALUE *argv, VALUE self)
{
    /* grab char pointer to markdown input text */
    char *res;
    int szres;
    VALUE encoding;
    VALUE text = rb_funcall(self, rb_intern("text"), 0);
    VALUE buf = rb_str_buf_new(1024);
    Check_Type(text, T_STRING);

    int flags = rb_rdiscount__get_flags(self);
    
    /* 
     * Force Discount to use ASCII character encoding for isalnum(), isalpha(),
     * and similar functions.
     * 
     * Ruby tends to use UTF-8 encoding, which is ill-defined for these
     * functions since they expect 8-bit codepoints (and UTF-8 has codepoints
     * of at least 21 bits).
     */
    char *old_locale = strdup(setlocale(LC_CTYPE, NULL));
    setlocale(LC_CTYPE, "C");   /* ASCII (and passthru characters > 127) */

    MMIOT *doc = mkd_string(RSTRING_PTR(text), RSTRING_LEN(text), flags);

    if ( mkd_compile(doc, flags) ) {
        szres = mkd_document(doc, &res);

        if ( szres != EOF ) {
            rb_str_cat(buf, res, szres);
            rb_str_cat(buf, "\n", 1);
        }
    }
    mkd_cleanup(doc);

    setlocale(LC_CTYPE, old_locale);
    free(old_locale);

    /* force the input encoding */
    if ( rb_respond_to(text, rb_intern("encoding")) ) {
        encoding = rb_funcall(text, rb_intern("encoding"), 0);
        rb_funcall(buf, rb_intern("force_encoding"), 1, encoding);
    }

    return buf;
}

static VALUE
rb_rdiscount_toc_content(int argc, VALUE *argv, VALUE self)
{
    char *res;
    int szres;

    int flags = rb_rdiscount__get_flags(self);

    /* grab char pointer to markdown input text */
    VALUE text = rb_funcall(self, rb_intern("text"), 0);
    Check_Type(text, T_STRING);

    /* allocate a ruby string buffer and wrap it in a stream */
    VALUE buf = rb_str_buf_new(4096);

    MMIOT *doc = mkd_string(RSTRING_PTR(text), RSTRING_LEN(text), flags);

    if ( mkd_compile(doc, flags) ) {
        szres = mkd_toc(doc, &res);

        if ( szres != EOF ) {
            rb_str_cat(buf, res, szres);
            rb_str_cat(buf, "\n", 1);
        }
    }
    mkd_cleanup(doc);

    return buf;
}


void Init_rdiscount()
{
    rb_cRDiscount = rb_define_class("RDiscount", rb_cObject);
    rb_define_method(rb_cRDiscount, "to_html", rb_rdiscount_to_html, -1);
    rb_define_method(rb_cRDiscount, "toc_content", rb_rdiscount_toc_content, -1);
}

/* vim: set ts=4 sw=4: */
