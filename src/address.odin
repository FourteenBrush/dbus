package dbus

import "core:c"
import "../src"

// Opaque type
AddressEntry :: distinct struct {}

@(default_calling_convention = "c", link_prefix = "dbus_")
foreign {
    address_entries_free :: proc(entries: [^]^AddressEntry) ---
    address_entry_entry_get_method :: proc(entry: ^AddressEntry) -> cstring ---
    address_entry_get_value :: proc(entry: ^AddressEntry, key: cstring) -> cstring ---
    parse_address :: proc(address: cstring, entry_result: ^[^]^AddressEntry, array_len: ^c.int, error: ^Error) ---
    parse_address_escape_value :: proc(value: string) -> cstring ---
    address_unescape_value :: proc(value: cstring, error: ^Error) ---
}
