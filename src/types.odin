package dbus

import "core:c"
import "core:sys/unix"
import win32 "core:sys/windows"

SERVICE_DBUS             :: "org.freedesktop.DBus"
PATH_DBUS                :: "/org/freedesktop/DBus"
PATH_LOCAL               :: "/org/freedesktop/DBus/Local"
INTERFACE_DBUS           :: "org.freedesktop.DBus"
INTERFACE_MONITORING     :: "org.freedesktop.DBus.Monitoring"
INTERFACE_VERBOSE        :: "org.freedesktop.DBus.Verbose"
INTERFACE_INTROSPECTABLE :: "org.freedesktop.DBus.Introspectable"
INTERFACE_PROPERTIES     :: "org.freedesktop.DBus.Properties"
INTERFACE_PEER           :: "org.freedesktop.DBus.Peer"
INTERFACE_LOCAL          :: "org.freedesktop.DBus.Local"

NAME_FLAG_ALLOW_REPLACEMENT :: 0x1
NAME_FLAG_REPLACE_EXISTING :: 0x2
NAME_FLAG_DO_NOT_QUEUE :: 0x4

REQUEST_NAME_REPLY_PRIMARY_OWNER :: 1
REQUEST_NAME_REPLY_IN_QUEUE :: 2
REQUEST_NAME_REPLY_EXISTS :: 3
REQUEST_NAME_REPLY_ALREADY_OWNER :: 4

RELEASE_NAME_REPLY_EXISTS :: 1
RELEASE_NAME_REPLY_NON_EXISTENT :: 2
RELEASE_NAME_REPLY_NOT_OWNER :: 3

START_REPLY_SUCCESS :: 1
START_REPLY_ALREADY_RUNNING :: 2

MAJOR_VERSION :: 1
MINOR_VERSION :: 15
MICRO_VERSION :: 8
VERSION :: (1 << 16) | (15 << 8) | 8
VERSION_STRING :: "1.15.8"

TIMEOUT_INFINITE :: 0x7fffffff
TIMEOUT_USE_DEFAULT :: -1

bool_t :: c.uint32_t
uid_t :: c.ulong
gid_t :: c.ulong
pid_t :: c.ulong

Atomic :: struct {
    value: c.int32_t, // volatile
}

BusType :: enum c.int {
    Session,
    System,
    Starter,
}

HandlerResult :: enum c.int {
    Handled,
    NotYetHandled,
    NeedMemory,
}

Connection :: struct {
    refcount: Atomic,
    mutex: ^RMutex,
    dispatch_mutex: ^CMutex,
    dispatch_cond: ^CondVar,
    io_path_mutex: ^CMutex,
    io_path_cond: ^CondVar,
    outgoing_messages: ^List,
    incoming_messages: ^List,
    expired_messages: ^List,
    message_borrowed: ^Message,
    n_outgoing: c.int,
    n_incoming: c.int,
    outgoing_counter: ^Counter,
    transport: ^Transport,
    watches: ^WatchList,
    timeouts: ^TimeoutList,
    filter_list: ^List,
    slot_mutex: ^RMutex,
    slot_list: DataSlotList,
    pending_replies: ^HashTable,
    client_serial: c.uint32_t,
    disconnect_message_link: ^List,
    wakeup_main_function: WakeupMainFunction,
    wakeup_main_data: rawptr,
    free_wakeup_main_data: FreeFunction,
    dispatch_status_function: DispatchStatusFunction,
    dispatch_status_data: rawptr,
    free_dispatch_status_data: FreeFunction,
    last_dispatch_status: DispatchStatus,
    objects: ObjectTree,
    server_guid: cstring,
    dispatch_acquired: bool_t,
    io_path_acquired: bool_t,
    shareable: c.uint,
    exit_on_disconnect: c.uint,
    builtin_filters_enabled: c.uint,
    route_peer_messages: c.uint,
    disconnected_message_arrived: c.uint,
    disconnected_message_proceeded: c.uint,
    have_connection_lock: c.uint,
}

RMutex :: struct {
    lock: unix.pthread_t,
}

CMutex :: struct {
    lock: unix.pthread_t,
}

when ODIN_OS == .Windows {
    CondVar :: struct {
        list: ^List,
        lock: win32.CRITICAL_SECTION
    }
} else {
    CondVar :: struct {
        cond: unix.pthread_cond_t,
    }
}

List :: struct {
    prev, next: ^List,
    data: rawptr,
}

// What on earth is this type???
String :: struct {
    dummy1: rawptr,
    dummy2: c.int,
    dummy3: c.int,
    dummy_bit1: c.uint,
    dummy_bit2: c.uint,
    dummy_bit3: c.uint,
    dummy_bits: c.uint,
}

HeaderField :: struct {
    value_pos: c.int,
}

Counter :: struct {
    refcount: c.int,
    size_value: c.long,
    unix_fd_value: c.long,
    notify_size_guard_value: c.long,
    notify_unix_fd_guard_value: c.long,
    notify_function: CounterNotificationFunction,
    notify_data: rawptr,
    notify_pending: bool_t,
    mutex: ^RMutex,
}

// TODO
CounterNotificationFunction :: #type proc()

Transport :: struct {
    refcount: c.int,
    vtable: ^TransportVTable,
    connection: ^Connection,
    loader: ^MessageLoader,
    auth: ^Auth,
    credentials: ^Credentials,
    max_live_messages_size: c.long,
    max_live_messages_unix_fds: c.long,
    live_messages: ^Counter,
    address: cstring,
    expected_guid: cstring,
    unix_user_function: AllowUnixUserFunction,
    unix_user_data: rawptr,
    free_unix_user_data: FreeFunction,
    windows_user_function: AllowWindowsUserFunction,
    windows_user_data: rawptr,
    free_windows_user_data: FreeFunction,
    disconnected: c.uint,
    authenticated: c.uint,
    send_credentials_pending: c.uint,
    receive_credentials_pending: c.uint,
    is_server: c.uint,
    unused_bytes_recovered: c.uint,
    allow_anonymous: c.uint,
}

TransportVTable :: struct {
    finalize: proc(transport: ^Transport),
    handle_watch: proc(transport: ^Transport, watch: ^Watch, flags: c.uint) -> bool_t,
    disconnect: proc(transport: ^Transport),
    connection_set: proc(transport: ^Transport) -> bool_t,
    do_iteration: proc(transport: ^Transport, flags: c.uint, timeout_milliseconds: c.int),
    live_messages_changed: proc(transport: ^Transport),
    get_socket_fd: proc(transport: ^Transport, fd_p: ^Socket) -> bool_t,
}

Watch :: struct {
    refcount: c.int,
    fd: Pollable,
    flags: c.uint,
    handler: WatchHandler,
    handler_data: rawptr,
    free_handler_data_function: FreeFunction,
    data: rawptr,
    free_data_function: FreeFunction,
    enabled: c.uint,
    oom_last_time: c.uint,
}

// TODO: probably has an epfd: c.int
Pollable :: distinct struct {}

WatchHandler :: #type proc(watch: ^Watch, flags: c.uint, data: rawptr) -> bool_t

FreeFunction :: #type proc(memory: rawptr)

Socket :: struct {
    fd: c.int,
}

MessageLoader :: struct {
    refcount: int,
    data: String,
    messages: ^List,
    max_message_size: c.long,
    max_message_unix_fds: c.long,
    corruption_reason: Validity,
    corrupted: c.uint,
    buffer_outstanding: c.uint,
}

Validity :: enum c.int {
    UnknownOomError,
    Valid,
    InvalidTooMuchData,
}

Auth :: struct {
    refcount: c.int,
    side: cstring,
    incoming: String,
    outgoing: String,
    state: ^AuthStateData,
    mech: ^AuthMechanismHandler,
    identity: String,
    credentials: ^Credentials,
    authorized_identity: ^Credentials,
    desired_identity: ^Credentials,
    ctx: String,
    keyring: ^Keyring,
    cookie_id: c.int,
    challenge: String,
    allowed_mechs: [^]cstring,
    needed_memory: c.uint,
    already_got_mechanisms: c.uint,
    already_asked_for_initial_response: c.uint,
    buffer_outstanding: c.uint,
    unix_fd_possible: c.uint,
    unix_fd_negotiated: c.uint,
}

AuthStateData :: struct {
    name: cstring,
    handler: AuthStateFunction,
}

AuthStateFunction :: #type proc(auth: ^Auth, command: AuthCommand, args: ^String) -> bool_t

AuthCommand :: enum c.int {
    Auth,
    Cancel,
    Data,
    Begin,
    Rejected,
    Ok,
    Error,
    Unknown,
    NegotiateUnixFd,
    AgreeUnixFd,
}

AuthMechanismHandler :: struct {
    mechanism: cstring,
    server_data_func: AuthDataFunction,
    server_encode_func: AuthEncodeFunction,
    server_decode_func: AuthDecodeFunction,
    server_shutdown_func: AuthShutdownFunction,
    client_initial_response_func: InitialResponseFunction,
    client_data_func: AuthDataFunction,
    client_encode_func: AuthEncodeFunction,
    client_decode_func: AuthDecodeFunction,
    client_shutdown_func: AuthShutdownFunction,
}

AuthDataFunction :: #type proc(auth: ^Auth, data: ^String) -> bool_t
AuthEncodeFunction :: #type proc(auth: ^Auth, data, encoded: ^String) -> bool_t
AuthDecodeFunction :: #type proc(auth: ^Auth, data, decoded: ^String) -> bool_t
AuthShutdownFunction :: #type proc(auth: ^Auth)
InitialResponseFunction :: #type proc(auth: ^Auth, response: ^String) -> bool_t

Credentials :: struct {
    refcount: c.int,
    unix_uid: uid_t,
    unix_gids: ^gid_t,
    n_unix_gids: c.size_t,
    pid: pid_t,
    pid_fd: c.int,
    windows_sid: cstring,
    linux_security_label: cstring,
    adt_audit_data: rawptr,
    adt_adut_data_size: c.int32_t,
}

Keyring :: struct {
    refcount: c.int,
    directory: String,
    filename: String,
    filename_lock: String,
    keys: ^Key,
    n_keys: c.int,
    credentials: ^Credentials,
}

Key :: struct {
    id: c.int32_t,
    creation_time: c.long,
    secret: String,
}

WatchList :: struct {
    watches: ^List,
    add_watch_function: AddWatchFunction,
    remove_watch_function: RemoveWatchFunction,
    watch_toggled_function: WatchToggledFunction,
    watch_data: rawptr,
    watch_free_data_function: FreeFunction,
}

TimeoutList :: struct {
    timeouts: ^List,
    add_timeout_function: AddTimeoutFunction,
    remove_timeout_function: RemoveTimeoutFunction,
    timeout_toggled_function: TimeoutToggledFunction,
    timeout_data: rawptr,
    timeout_free_data_function: FreeFunction,
}

Timeout :: struct {
    refcount: c.int,
    interval: c.int,
    handler: TimeoutHandler,
    handler_data: rawptr,
    free_handler_data_function: FreeFunction,
    data: rawptr,
    free_data_function: FreeFunction,
    enabled: c.uint,
    needs_restart: c.uint,
}

TimeoutHandler :: #type proc(data: rawptr) -> bool_t

DataSlotList :: struct {
    slots: ^DataSlot,
    n_slots: c.int,
}

DataSlot :: struct {
    data: rawptr,
    free_data_func: FreeFunction,
}

HashTable :: struct {
    refcount: c.int,
    buckets: [^]^HashEntry,
    static_buckets: [SMALL_HASH_TABLE]^HashEntry,
    n_buckets: c.int,
    n_entries: c.int,
    hi_rebuild_size: c.int,
    lo_rebuild_size: c.int,
    down_shift: c.int,
    mask: c.int,
    key_type: HashType,
    find_function: FindEntryFunction,
    free_key_function: FreeFunction,
    free_value_function: FreeFunction,
    entry_pool: ^MemPool,
}

SMALL_HASH_TABLE :: 4

HashEntry :: struct {
    next: ^HashEntry,
    key: rawptr,
    value: rawptr,
}

HashType :: enum c.int {
    HashString,
    HashInt,
    HashUintptr,
}

FindEntryFunction :: #type proc(
    table: ^HashTable, key: rawptr, create_if_not_found: bool_t, 
    bucket: [^][^]^HashEntry, preallocated: ^PreallocatedHash,
) -> ^HashEntry

// Opaque type, wasn't able to find any definition
// https://gitlab.freedesktop.org/dbus/dbus/-/blob/master/dbus/dbus-hash.h#L150
// I noticed the following fields though: 
// - queue_link
// - counter_link -> data
// - connection
PreallocatedHash :: distinct struct {}

MemPool :: struct {
    element_size: c.size_t,
    block_size: c.size_t,
    zero_elements: c.uint,
    free_elements: ^FreedElement,
    blocks: ^MemBlock,
    allocated_elements: c.int,
}

FreedElement :: struct {
    next: ^FreedElement
}

MemBlock :: struct {
    next: ^MemBlock,
    used_so_far: c.size_t,
    elements: [0]c.uchar,
}

ObjectTree :: struct {
    refcount: c.int,
    connection: ^Connection,
    root: ^ObjectSubtree,
}

ObjectSubtree :: struct {
    refcount: Atomic,
    parent: ^ObjectSubtree,
    unregister_function: ObjectPathUnregisterFunction,
    message_function: ObjectPathMessageFunction,
    user_data: rawptr,
    subtrees: [^]^ObjectSubtree,
    n_subtrees: c.int,
    max_subtrees: c.int,
    invoke_as_fallback: c.uint,
    name: [1]c.char,
}

