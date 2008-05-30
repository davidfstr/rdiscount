#define _GNU_SOURCE

#include <stdlib.h>
#include "rbstrio.h"

#define INCREMENT 1024

/* called when data is written to the stream. */
static int rb_str_io_write(void *cookie, const char *data, int len) {
    VALUE buf = (VALUE)cookie;
    rb_str_cat(buf, data, len);
    return len;
}

/* called when the stream is closed */
static int rb_str_io_close(void *cookie) {
    VALUE buf = (VALUE)cookie;
    rb_gc_unregister_address(&buf);
    return 0;
}

#ifdef __GLIBC__
cookie_io_functions_t rb_str_io_functions =
{
    (cookie_read_function_t*)NULL,
    (cookie_write_function_t*)rb_str_io_write,
    (cookie_seek_function_t*)NULL,
    (cookie_close_function_t*)rb_str_io_close
};
#endif

/* create a stream backed by a Ruby string. */
FILE *rb_str_io_new(VALUE buf) {
    FILE *rv;
    Check_Type(buf, T_STRING);
#ifdef __GLIBC__
    rv = fopencookie((void*)buf, "w", rb_str_io_functions);
#else
    rv = funopen((void*)buf, NULL, rb_str_io_write, NULL, rb_str_io_close);
#endif
    /* TODO if (rv == NULL) */
    rb_gc_register_address(&buf);
    return rv;
}

// vim: ts=4 sw=4
