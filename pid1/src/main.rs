use std::ffi::CString;

use nix::{
    libc,
    sys::wait::waitpid,
    unistd::{execv, fork, write, ForkResult},
};

fn main() {
    match unsafe { fork() } {
        Ok(ForkResult::Child) => {
            write(libc::STDOUT_FILENO, "Spawning new shell".as_bytes()).ok();

            let shell_path = CString::new("/shell").unwrap();
            let args = &[CString::new("empty").unwrap()];
            execv(&shell_path, args).ok();

            unsafe { libc::_exit(0) }
        }

        Ok(ForkResult::Parent { child }) => {
            println!("Spawning new child {child}");
            waitpid(child, None).unwrap();
        }

        Err(err) => {
            println!("Fork fail! {err}");
        }
    }
}
