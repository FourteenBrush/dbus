package dbus

import "core:c"
import "core:c/libc"

main :: proc() {}

Error :: struct {
    name: cstring,
    message: cstring,
    dummy: [5]c.int,
    padding: rawptr,
}

@(default_calling_convention = "c", link_prefix = "dbus_")
foreign {
    error_init :: proc(error: ^Error) ---
    error_free :: proc(error: ^Error) ---
    set_error_const :: proc(error: ^Error, name, message: cstring) ---
    move_error :: proc(src, dest: ^Error) ---
    error_has_name :: proc(error: ^Error, name: cstring) -> bool_t ---
    error_is_set :: proc(error: ^Error) -> bool_t ---
    set_error :: proc(error: ^Error, name, format: cstring, #c_vararg args: ..any) ---
    @(link_prefix = "_dbus_")
    set_error_valist :: proc(error: ^Error, name, format, args: libc.va_list) ---
}
