#[derive(Clone, Debug)]
#[repr(C)]
pub struct Doggo {
    age: i32,
    name: *const u8,
}

impl Doggo {
    fn new() -> Doggo {
        Doggo {
            age: 1,
            name: "My name is Doggo!".as_ptr(),
        }
    }
    fn call_name(&mut self, name: *const u8) {
        self.name = name;
    }
}

impl Default for Doggo {
    fn default() -> Self {
        Self::new()
    }
}

#[no_mangle]
pub extern "C" fn call_name(ptr: *mut Doggo, name: *const u8) {
    let call: &mut Doggo = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    call.call_name(name);
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
