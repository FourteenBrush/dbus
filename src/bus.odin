package dbus

import "core:c"
import "../src"

@(default_calling_convention = "c", link_prefix = "dbus_")
foreign {
    bus_get :: proc(type: BusType, error: ^Error) -> ^Connection ---
    bus_get_private :: proc(type: BusType, error: ^Error) -> ^Connection ---
    bus_register :: proc(connection: ^Connection, error: ^Error) -> bool_t ---
    bus_set_unique_name :: proc(connection: ^Connection, unique_name: cstring) -> bool_t ---
    bus_get_unique_name :: proc(connection: ^Connection) -> cstring ---
    bus_get_unix_user :: proc(connection: ^Connection, name: cstring, error: ^Error) -> c.ulong ---
    bus_get_id :: proc(connection: ^Connection, error: ^Error) -> cstring ---
    bus_request_name :: proc(connection: ^Connection, name: cstring, flags: c.uint, error: ^Error) -> c.int ---
    bus_release_name :: proc(connection: ^Connection, name: cstring, error: ^Error) -> c.int ---
    bus_name_has_owner :: proc(connection: ^Connection, name: cstring, error: ^Error) -> bool_t ---
    bus_start_service_by_name :: proc(connection: ^Connection, name: cstring, flags: c.uint32_t, result: ^c.uint32_t, error: ^Error) -> bool_t ---
    bus_add_match :: proc(connection: ^Connection, rule: cstring, error: ^Error) ---
    bus_remove_match :: proc(connection: ^Connection, rule: cstring, error: ^Error) ---
}
