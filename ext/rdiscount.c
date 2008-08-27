#include <stdio.h>
#include "ruby.h"
#include "mkdio.h"
#include "rbstrio.h"

static VALUE rb_cRDiscount;

static VALUE
rb_rdiscount_to_html(int argc, VALUE *argv, VALUE self)
{
    /* grab char pointer to markdown input text */
    VALUE text = rb_funcall(self, rb_intern("text"), 0);
    Check_Type(text, T_STRING);

    /* allocate a ruby string buffer and wrap it in a stream */
    VALUE buf = rb_str_buf_new(4096);
    FILE *stream = rb_str_io_new(buf);

    /* compile flags */
    int flags = MKD_TABSTOP | MKD_NOHEADER;

    /* smart */
    if ( rb_funcall(self, rb_intern("smart"), 0) != Qtrue )
        flags = flags | MKD_NOPANTS;

    /* filter_html */
    if ( rb_funcall(self, rb_intern("filter_html"), 0) == Qtrue )
        flags = flags | MKD_NOHTML;

    MMIOT *doc = mkd_string(RSTRING(text)->ptr, RSTRING(text)->len, flags);
    markdown(doc, stream, flags);

    fclose(stream);

    return buf;
}

void Init_rdiscount()
{
    rb_cRDiscount = rb_define_class("RDiscount", rb_cObject);
    rb_define_method(rb_cRDiscount, "to_html", rb_rdiscount_to_html, -1);
}

/* vim: set ts=4 sw=4: */
