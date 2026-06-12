#![no_main]
#![no_std]
extern crate panic_halt;

use core::ffi::{c_char, c_int};

unsafe extern "C" {
    fn printf(fmt: *const c_char, ...);
}

#[macro_export]
macro_rules! println {
    ($fmt:literal $(, $arg:expr)* $(,)?) => {{
        unsafe {
            printf(
                concat!($fmt, "\n\0").as_ptr() as *const core::ffi::c_char,
                $($arg),*
            );
        }
    }};
}

#[unsafe(no_mangle)]
pub extern "C" fn hello_rust() {
    println!("Hello from rust %d !", 69);
}
