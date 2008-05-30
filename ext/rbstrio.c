#include "rbstrio.h"
#include "ruby.h"

#define INCREMENT 1024

/* called when data is written to the stream. */
static int rb_str_io_write(void *cookie, const char *data, int len) {
    VALUE buf = cookie;
    rb_str_cat(buf, data, len);
    return len;
}

/* called when the stream is closed */
static int rb_str_io_close(void *cookie) {
    rb_gc_unregister_address(&cookie);
    return 0;
}

/* create a stream backed by a Ruby string. */
FILE *rb_str_io_new(VALUE buf) {
    FILE *rv;
    Check_Type(buf, T_STRING);
    rv = funopen(buf, NULL, rb_str_io_write, NULL, rb_str_io_close);
    /* TODO if (rv == NULL) */
    rb_gc_register_address(&buf);
    return rv;
}

// vim: ts=4 sw=4
