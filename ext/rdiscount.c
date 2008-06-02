#include <stdio.h>
#include "ruby.h"
#include "mkdio.h"
#include "rbstrio.h"

static VALUE rb_cRDiscount;

static ID id_text;
static ID id_smart;
static ID id_notes;


static VALUE
rb_rdiscount_to_html(int argc, VALUE *argv, VALUE self)
{
    /* grab char pointer to markdown input text */
    VALUE text = rb_funcall(self, id_text, 0);
    Check_Type(text, T_STRING);

    /* allocate a ruby string buffer and wrap it in a stream */
    VALUE buf = rb_str_buf_new(4096);
    FILE *stream = rb_str_io_new(buf);

    /* compile flags */
    int flags = MKD_TABSTOP | MKD_NOHEADER;
    if (rb_funcall(self, id_smart, 0) != Qtrue )
        flags = flags | MKD_NOPANTS;

    MMIOT *doc = mkd_string(RSTRING(text)->ptr, RSTRING(text)->len, flags);
    markdown(doc, stream, flags);

    fclose(stream);

    return buf;
}

void Init_rdiscount()
{
    /* Initialize frequently used Symbols */
    id_text  = rb_intern("text");
    id_smart = rb_intern("smart");
    id_notes = rb_intern("notes");

    rb_cRDiscount = rb_define_class("RDiscount", rb_cObject);
    rb_define_method(rb_cRDiscount, "to_html", rb_rdiscount_to_html, -1);
}

/* vim: set ts=4 sw=4: */
