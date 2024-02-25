package dbus

import "core:path/filepath"

import "../bindgen"

main :: proc() {
    foreign_lib :: "../lib"
    header_files, err := filepath.glob("../lib/*.h")
    assert(err == .None)

    options := bindgen.GeneratorOptions {
        functionPrefixes = {"dbus_"},
        functionCase = bindgen.Case.Snake,
        enumValuePrefixes = {"DBUS_"},
        enumValueCase = bindgen.Case.Snake,
        pseudoTypePrefixes = {"DBus"},
        pseudoTypeCase = bindgen.Case.Snake,
    }

    options.parserOptions.ignoredTokens = {"typedef struct DBusAddressEnty DBusAddressEntry"}

    bindgen.generate("dbus", foreign_lib, "bindings.odin", header_files, options)
}
