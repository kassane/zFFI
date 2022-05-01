use std::env;

fn main() {
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();

    let binding = cbindgen::Builder::new();
    cbindgen::Builder::with_language(binding, cbindgen::Language::Zig)
        .with_crate(crate_dir)
        .generate()
        .expect("Unable to generate bindings")
        .write_to_file("generated/binding.zig");
}
