use std::ffi::{CStr, CString};
use std::os::raw::c_char;

#[repr(C)]
pub struct Doggo {
    age: i32,
    name: CString,
}

impl Doggo {
    fn new() -> Doggo {
        Doggo {
            age: 1,
            name: CString::new("My name is Doggo!").unwrap(),
        }
    }
    fn call_name(&mut self, name: &CStr) {
        self.name = CString::new(name.to_str().unwrap()).unwrap();
    }
}

impl Default for Doggo {
    fn default() -> Self {
        Self::new()
    }
}

#[no_mangle]
pub extern "C" fn call_name(ptr: *mut Doggo, name: *const c_char) {
    let call: &mut Doggo = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    call.call_name(unsafe { CStr::from_ptr(name) });
}

#[no_mangle]
pub extern "C" fn is_whitespace(byte: u8) -> bool {
    match byte {
        b' ' | b'\x09'..=b'\x0d' => true,
        _ => false,
    }
}

#[no_mangle]
pub extern "C" fn mul(value1: usize, value2: usize) -> usize {
    value1 * value2
}

#[no_mangle]
pub extern "C" fn add(value1: usize, value2: usize) -> usize {
    value1 + value2
}
