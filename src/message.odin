package dbus

import "core:c"
import "core:c/libc"

HEADER_FIELD_LAST :: HEADER_FIELD_CONTAINER_INSTANCE
HEADER_FIELD_CONTAINER_INSTANCE :: 10

Message :: struct {
    refcount: Atomic,
    header: Header,
    body: String,
    locked: c.uint,
    in_cache: c.uint,
    counters: ^List,
    size_counter_delta: c.long,
    changed_stamp: u32,
    slot_list: ^List,
    generation: c.int,
}

Header :: struct {
    data: String,
    fields: [HEADER_FIELD_LAST + 1]HeaderField,
    padding: u32,
    byte_order: u32,
}

// Opaque type
MessageIter :: distinct struct {}

@(default_calling_convention = "c", link_prefix = "dbus_")
foreign {
    message_get_serial :: proc(message: ^Message) -> c.uint32_t ---
    message_set_reply_serial :: proc(message: ^Message, reply_serial: c.uint32_t) -> bool_t ---
    message_get_reply_serial :: proc(message: ^Message) -> c.uint32_t ---
    message_new :: proc(message_type: c.int) -> ^Message ---
    message_new_method_call :: proc(destination, path, iface, method: cstring) -> ^Message ---
    message_new_method_return :: proc(method_call: ^Message) -> ^Message ---
    message_new_signal :: proc(path, iface, name: cstring) -> ^Message ---
    message_new_error :: proc(reply_to: ^Message, error_name, error_message: cstring) -> ^Message ---
    message_new_error_printf :: proc(reply_to: ^Message, error_name, error_format: cstring, #c_vararg args: ..any) -> ^Message ---
    message_copy :: proc(message: ^Message) -> ^Message ---
    message_ref :: proc(message: ^Message) -> ^Message ---
    message_unref :: proc(message: ^Message) ---
    message_get_type :: proc(^Message) -> c.int ---
    message_append_args :: proc(message: ^Message, first_arg_type: c.int, #c_vararg args: ..any) -> bool_t ---
    message_append_args_valist :: proc(message: ^Message, first_arg_type: c.int, var_args: libc.va_list) -> bool_t ---
    message_get_args :: proc(message: ^Message, error: ^Error, first_arg_type: c.int, #c_vararg args: ..any) -> bool_t ---
    message_get_args_valist :: proc(message: ^Message, error: ^Error, first_arg_type: c.int, var_args: libc.va_list) -> bool_t ---
    message_iter_init :: proc(message: ^Message, iter: ^MessageIter) -> bool_t ---
    message_iter_has_next :: proc(iter: ^MessageIter) -> bool_t ---
    message_iter_next :: proc(iter: ^MessageIter) -> bool_t ---
    message_iter_get_arg_type :: proc(iter: ^MessageIter) -> c.int ---
    message_iter_get_element_type :: proc(iter: ^MessageIter) -> c.int ---
    message_iter_recurse :: proc(iter, sub: ^MessageIter) ---
    message_iter_get_signature :: proc(iter: ^MessageIter) -> cstring ---
    message_iter_get_basic :: proc(iter: ^MessageIter, value: rawptr) ---
    message_iter_get_element_count :: proc(iter: ^MessageIter) -> c.int ---
    message_iter_get_array_len :: proc(iter: ^MessageIter) -> c.int ---
    message_iter_get_fixed_array :: proc(iter: ^MessageIter, value: rawptr, n_elements: ^c.int) ---
    message_iter_init_append :: proc(message: ^Message, iter: ^MessageIter) ---
    message_iter_append_basic :: proc(iter: ^MessageIter, type: c.int, value: rawptr) -> bool_t ---
    message_iter_open_container :: proc(iter: ^MessageIter, type: c.int, contained_signature: cstring, sub: ^MessageIter) -> bool_t ---
    message_iter_close_container :: proc(iter, sub: ^MessageIter) -> bool_t ---
    message_iter_abandon_container :: proc(iter, sub: ^MessageIter) ---
    message_iter_abandon_container_if_open :: proc(iter, sub: ^MessageIter) ---
    message_set_no_reply :: proc(message: ^Message, no_reply: bool_t) ---
    message_get_no_reply :: proc(message: ^Message) -> bool_t ---
    message_set_auto_start :: proc(message: ^Message, auto_start: bool_t) ---
    message_get_auto_start :: proc(message: ^Message) -> bool_t ---
    message_set_path :: proc(message: ^Message, object_path: cstring) -> bool_t ---
    message_get_path :: proc(message: ^Message) -> cstring ---
    message_has_path :: proc(message: ^Message, path: cstring) -> bool_t ---
    message_get_path_decomposed :: proc(message: ^Message, path: ^[^]cstring) -> bool_t ---
    message_set_interface :: proc(message: ^Message, iface: cstring) -> bool_t ---
    message_get_interface :: proc(message: ^Message) -> cstring ---
    message_has_interface :: proc(message: ^Message, iface: cstring) -> bool_t ---
    message_set_member :: proc(message: ^Message, member: cstring) -> bool_t ---
    
}
