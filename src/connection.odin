package dbus

import "core:c"

// Opaque type
PreallocatedSend :: distinct struct {}

ObjectPathVTable :: struct {
    unregister_function: ObjectPathUnregisterFunction,
    message_function: ObjectPathMessageFunction,
    internal_pad1: proc(rawptr),
    internal_pad2: proc(rawptr),
    internal_pad3: proc(rawptr),
    internal_pad4: proc(rawptr),
}

AddWatchFunction :: #type proc(watch: ^Watch, data: rawptr) -> bool_t
WatchToggledFunction :: #type proc(watch: ^Watch, data: rawptr)
RemoveWatchFunction :: #type proc(watch: ^Watch, data: rawptr)

AddTimeoutFunction :: #type proc(timeout: ^Timeout, data: rawptr) -> bool_t
TimeoutToggledFunction :: #type proc(timeout: ^Timeout, data: rawptr)
RemoveTimeoutFunction :: #type proc(timeout: ^Timeout, data: rawptr)

DispatchStatusFunction :: #type proc(conn: ^Connection, new_status: DispatchStatus, data: rawptr)

WakeupMainFunction :: #type proc(data: rawptr)

AllowUnixUserFunction :: #type proc(conn: ^Connection, uid: c.ulong, data: rawptr) -> bool_t
AllowWindowsUserFunction :: #type proc(conn: ^Connection, user_sid: cstring, data: rawptr) -> bool_t

PendingCallNotifyFunction :: #type proc(pending: ^PendingCall, user_data: rawptr)

PendingCall :: struct {
    refcount: Atomic,
    slot_list: DataSlotList,
    function: PendingCallNotifyFunction,
    conn: ^Connection,
    reply: ^Message,
    timeout: ^Timeout,
    timeout_link: ^List,
    reply_serial: c.uint32_t,
    completed: c.uint,
    timeout_added: c.uint,
}

HandleMessageFunction :: #type proc(conn: ^Connection, message: ^Message, user_data: rawptr)

ObjectPathUnregisterFunction :: #type proc(conn: ^Connection, user_data: rawptr)
ObjectPathMessageFunction :: #type proc(conn: ^Connection, message: ^Message, user_data: rawptr) -> HandlerResult

WatchFlags :: enum c.int {
    Readable,
    Writable,
    Error,
    Hangup,
}

DispatchStatus :: enum c.int {
    DataRemains,
    Complete,
    NeedsMemory,
}

@(default_calling_convention = "c", link_prefix = "dbus_")
foreign {
    connection_open :: proc(address: cstring, error: ^Error) -> ^Connection ---
    connection_open_private :: proc(address: cstring, error: ^Error) -> ^Connection ---
    connection_ref :: proc(conn: ^Connection) -> ^Connection ---
    connection_unref :: proc(conn: ^Connection) ---
    connection_close :: proc(conn: ^Connection) ---
    connection_get_is_connected :: proc(conn: ^Connection) -> bool_t ---
    connection_get_is_authenticated :: proc(conn: ^Connection) -> bool_t ---
    connection_get_is_anonymous :: proc(conn: ^Connection) -> bool_t ---
    connection_get_server_id :: proc(conn: ^Connection) -> cstring ---
    connection_can_send_type :: proc(conn: ^Connection, type: c.int) -> bool_t ---
    connection_set_exit_on_disconnect :: proc(conn: ^Connection, exit_on_disconnect: bool_t) ---
    connection_preallocate_send :: proc(conn: ^Connection) -> ^PreallocatedSend ---
    connection_free_preallocated_send :: proc(conn: ^Connection, preallocated: ^PreallocatedSend) ---
    connection_send_preallocated :: proc(conn: ^Connection, preallocated: ^PreallocatedSend, message: ^Message, client_serial: ^c.uint32_t) ---
    connection_send :: proc(conn: ^Connection, message: ^Message, serial: ^c.uint32_t) -> bool_t ---
    connection_send_with_reply :: proc(conn: ^Connection, message: ^Message, pending_return: ^^PendingCall, timeout_millis: c.int) -> bool_t ---
    connection_send_with_reply_and_block :: proc(conn: ^Connection, message: ^Message, timeout_millis: c.int, error: ^Error) -> ^Message ---
    connection_flush :: proc(conn: ^Connection) ---
    connection_read_write_dispatch :: proc(conn: ^Connection, timeout_millis: c.int) -> bool_t ---
    connection_red_write :: proc(conn: ^Connection, timeout_millis: c.int) -> bool_t ---
    connection_borrow_message :: proc(conn: ^Connection) -> ^Message ---
    connection_return_message :: proc(conn: ^Connection, message: ^Message) ---
    connection_steal_borrowed_message :: proc(coonn: ^Connection, message: ^Message) ---
    connection_pop_message :: proc(conn: ^Connection) -> ^Message ---
    connection_get_dispatch_status :: proc(conn: ^Connection) -> DispatchStatus ---
    connection_dispatch :: proc(conn: ^Connection) -> DispatchStatus ---
    connection_set_watch_functions :: proc(
        conn: ^Connection,
        add_function: AddWatchFunction,
        remove_function: RemoveWatchFunction,
        toggled_function: WatchToggledFunction,
        data: rawptr,
        free_data_function: FreeFunction,
    ) -> bool_t ---
    connection_set_timout_functions :: proc(
        conn: ^Connection,
        add_function: AddTimeoutFunction,
        remove_function: RemoveTimeoutFunction,
        toggled_function: TimeoutToggledFunction,
        data: rawptr,
        free_data_function: FreeFunction,
    ) ---
    connection_set_wakup_main_function :: proc(
        conn: ^Connection,
        wakeup_main_function: WakeupMainFunction,
        data: rawptr,
        free_data_function: FreeFunction,
    ) ---
    connection_set_dispatch_status_function :: proc(
        conn: ^Connection,
        function: DispatchStatusFunction,
        data: rawptr,
        free_data_function: FreeFunction,
    ) ---
    connection_get_unix_fd :: proc(conn: ^Connection, fd: ^c.int) -> bool_t ---
    connection_get_socket :: proc(conn: ^Connection, fd: ^c.int) -> bool_t ---
    connection_get_unix_user :: proc(conn: ^Connection, uid: ^c.ulong) -> bool_t ---
    connection_get_unix_process_id :: proc(conn: ^Connection, pid: ^c.ulong) -> bool_t ---
    connection_get_adt_audit_session_data :: proc(conn: ^Connection, data: ^rawptr, data_size: c.int32_t) -> bool_t ---
    connection_set_unix_user_function :: proc(
        conn: ^Connection,
        function: AllowUnixUserFunction,
        data: rawptr,
        free_data_function: FreeFunction,
    ) ---
    @(link_prefix = "_dbus_")
    connection_get_linux_security_label :: proc(conn: ^Connection, label_p: ^cstring) -> bool_t ---
    @(link_prefix = "_dbus_")
    connection_get_credentials :: proc(conn: ^Connection) -> ^Credentials ---
    connection_get_windows_user :: proc(conn: ^Connection, windows_sid_p: ^cstring) -> bool_t ---
    connection_set_windows_user_function :: proc(
        conn: ^Connection,
        function: AllowWindowsUserFunction,
        data: rawptr,
        free_data_function: FreeFunction,
    ) ---
    connection_set_allow_anonymous :: proc(conn: ^Connection, value: bool_t) ---
    connection_set_builtin_filters_enabled :: proc(conn: ^Connection, value: bool_t) ---
    connection_set_route_peer_messages :: proc(conn: ^Connection, value: bool_t) ---
    connection_add_filter :: proc(
        conn: ^Connection,
        function, HandleMessageFunction,
        user_data: rawptr,
        free_data_function: FreeFunction,
    ) -> bool_t ---
    connection_remove_filter :: proc(conn: ^Connection, function: HandleMessageFunction, user_data: rawptr) ---
    connection_try_register_object_path :: proc(
        conn: ^Connection,
        path: cstring,
        vtable: ^ObjectPathVTable,
        user_data: rawptr,
        error: ^Error,
    ) -> bool_t ---
    connection_register_object_path :: proc(
        conn: ^Connection,
        path: cstring, 
        vtable: ^ObjectPathVTable, 
        user_data: rawptr,
    ) -> bool_t ---
    connection_try_register_fallback :: proc(
        conn: ^Connection,
        path: cstring,
        vtable: ^ObjectPathVTable,
        user_data: rawptr,
        error: ^Error,
    ) -> bool_t ---
    connection_register_fallback :: proc(
        conn: ^Connection,
        path: cstring,
        vtable: ^ObjectPathVTable,
        user_data: rawptr,
    ) -> bool_t ---
    connection_unregister_object_path :: proc(conn: ^Connection, path: cstring) -> bool_t ---
    connection_get_object_path_data :: proc(conn: ^Connection, path: cstring, data_p: ^rawptr) -> bool_t ---
    connection_list_registered :: proc(conn: ^Connection, parent_path: cstring, child_entries: ^[^]^c.char) -> bool_t ---
    connection_allocate_data_slot :: proc(slot_p: ^c.int32_t) -> bool_t ---
    connection_free_data_slot :: proc(slot_p: ^c.int32_t) ---
    connection_set_data :: proc(conn: ^Connection, slot: c.int32_t, data: rawptr, data_free_func: FreeFunction) -> bool_t ---
    connection_get_data :: proc(conn: ^Connection, slot: c.int32_t) -> rawptr ---
    connection_set_change_sigpipe :: proc(will_modify_sigpipe: bool_t) ---
    connection_set_max_message_size :: proc(conn: ^Connection, size: c.long) ---
    connection_get_max_message_size :: proc(conn: ^Connection) -> c.long ---
    connection_set_max_message_unix_fds :: proc(conn: ^Connection, n: c.long) ---
    connection_get_max_unix_fds :: proc(conn: ^Connection) -> c.long ---
    connection_set_max_received_size :: proc(conn: ^Connection, size: c.long) ---
    connection_get_max_received_size :: proc(conn: ^Connection) -> c.long ---
    connection_set_max_received_unix_fds :: proc(conn: ^Connection, n: c.long) ---
    connection_get_max_received_unix_fds :: proc(conn: ^Connection) -> c.long ---
    connection_get_outgoing_size :: proc(conn: ^Connection) -> c.long ---
    connection_get_outgoing_unix_fds :: proc(conn: ^Connection) -> c.long ---
    connection_has_messages_to_send :: proc(conn: ^Connection) -> bool_t ---
}
