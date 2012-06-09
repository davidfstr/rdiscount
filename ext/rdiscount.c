#include <stdio.h>
#include "ruby.h"
#include "mkdio.h"

static VALUE rb_cRDiscount;

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

    MMIOT *doc = mkd_string(RSTRING_PTR(text), RSTRING_LEN(text), flags);

    if ( mkd_compile(doc, flags) ) {
        szres = mkd_document(doc, &res);

        if ( szres != EOF ) {
            rb_str_cat(buf, res, szres);
            rb_str_cat(buf, "\n", 1);
        }
    }
    mkd_cleanup(doc);


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

int rb_rdiscount__get_flags(VALUE ruby_obj)
{
    VALUE flags = rb_funcall(ruby_obj, rb_intern("flags"), 0);
    return NUM2INT(rb_funcall(flags, rb_intern("to_i"), 0));
}

void Init_rdiscount()
{
    rb_cRDiscount = rb_define_class("RDiscount", rb_cObject);
    rb_define_const(rb_cRDiscount, "MKD_NOLINKS", INT2NUM(MKD_NOLINKS));
    rb_define_const(rb_cRDiscount, "MKD_NOIMAGE", INT2NUM(MKD_NOIMAGE));
    rb_define_const(rb_cRDiscount, "MKD_NOPANTS", INT2NUM(MKD_NOPANTS));
    rb_define_const(rb_cRDiscount, "MKD_NOHTML", INT2NUM(MKD_NOHTML));
    rb_define_const(rb_cRDiscount, "MKD_STRICT", INT2NUM(MKD_STRICT));
    rb_define_const(rb_cRDiscount, "MKD_TAGTEXT", INT2NUM(MKD_TAGTEXT));
    rb_define_const(rb_cRDiscount, "MKD_NO_EXT", INT2NUM(MKD_NO_EXT));
    rb_define_const(rb_cRDiscount, "MKD_CDATA", INT2NUM(MKD_CDATA));
    rb_define_const(rb_cRDiscount, "MKD_NOSUPERSCRIPT", INT2NUM(MKD_NOSUPERSCRIPT));
    rb_define_const(rb_cRDiscount, "MKD_NORELAXED", INT2NUM(MKD_NORELAXED));
    rb_define_const(rb_cRDiscount, "MKD_NOTABLES", INT2NUM(MKD_NOTABLES));
    rb_define_const(rb_cRDiscount, "MKD_NOSTRIKETHROUGH", INT2NUM(MKD_NOSTRIKETHROUGH));
    rb_define_const(rb_cRDiscount, "MKD_TOC", INT2NUM(MKD_TOC));
    rb_define_const(rb_cRDiscount, "MKD_1_COMPAT", INT2NUM(MKD_1_COMPAT));
    rb_define_const(rb_cRDiscount, "MKD_AUTOLINK", INT2NUM(MKD_AUTOLINK));
    rb_define_const(rb_cRDiscount, "MKD_SAFELINK", INT2NUM(MKD_SAFELINK));
    rb_define_const(rb_cRDiscount, "MKD_NOHEADER", INT2NUM(MKD_NOHEADER));
    rb_define_const(rb_cRDiscount, "MKD_TABSTOP", INT2NUM(MKD_TABSTOP));
    rb_define_const(rb_cRDiscount, "MKD_NODIVQUOTE", INT2NUM(MKD_NODIVQUOTE));
    rb_define_const(rb_cRDiscount, "MKD_NOALPHALIST", INT2NUM(MKD_NOALPHALIST));
    rb_define_const(rb_cRDiscount, "MKD_NODLIST", INT2NUM(MKD_NODLIST));
    rb_define_method(rb_cRDiscount, "to_html", rb_rdiscount_to_html, -1);
    rb_define_method(rb_cRDiscount, "toc_content", rb_rdiscount_toc_content, -1);
}

/* vim: set ts=4 sw=4: */
