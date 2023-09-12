extern crate tokio;

use tokio::time::{Duration, sleep};
use std::sync::{Arc, Mutex};

// Define a simple struct to hold data shared between Rust and C
struct SharedData {
    counter: i32,
}

impl SharedData {
    fn new() -> Self {
        SharedData { counter: 0 }
    }

    fn increment(&mut self) {
        self.counter += 1;
    }

    fn get_counter(&self) -> i32 {
        self.counter
    }
}

// ...

// Define a global reference to the shared data
static mut SHARED_DATA: Option<Arc<Mutex<SharedData>>> = None;

#[no_mangle]
pub extern "C" fn init_shared_data() {
    unsafe {
        SHARED_DATA = Some(Arc::new(Mutex::new(SharedData::new())));
    }
}

#[no_mangle]
pub extern "C" fn start_event_loop(limit: i32) {
    let shared_data = unsafe { SHARED_DATA.as_ref().unwrap().clone() };

    let rt = tokio::runtime::Runtime::new().expect("Unable to create Tokio runtime");

    rt.block_on(async {
        let mut counter = 0;
        while counter < limit {
            // Simulate an asynchronous task
            sleep(Duration::from_secs(1)).await;

            // Access and modify the shared data
            let mut data = shared_data.lock().unwrap();
            data.increment();
            counter = data.get_counter();

            // Print the counter value
            println!("Counter: {}", counter);
        }

        println!("Counter reached the limit. Stopping the event loop...");
    });
}


#[no_mangle]
pub extern "C" fn get_counter() -> i32 {
    let shared_data = unsafe { SHARED_DATA.as_ref().unwrap().clone() };
    let data = shared_data.lock().unwrap();
    data.get_counter()
}

#[no_mangle]
pub extern "C" fn shutdown_event_loop() {
    // Graceful shutdown logic can be implemented here
    println!("Shutting down the event loop...");
}
