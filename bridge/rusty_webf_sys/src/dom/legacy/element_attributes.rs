// Generated by WebF TSDL, don't edit this file directly.
// Generate command: node scripts/generate_binding_code.js
/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::*;
use crate::*;
#[repr(C)]
enum ElementAttributesType {
  ElementAttributes = 0,
}
#[repr(C)]
pub struct ElementAttributesRustMethods {
  pub version: c_double,
  pub get_attribute: extern "C" fn(*const OpaquePtr, *const c_char, *const OpaquePtr) -> AtomicStringRef,
  pub set_attribute: extern "C" fn(*const OpaquePtr, *const c_char, *const c_char, *const OpaquePtr) -> c_void,
  pub has_attribute: extern "C" fn(*const OpaquePtr, *const c_char, *const OpaquePtr) -> i32,
  pub remove_attribute: extern "C" fn(*const OpaquePtr, *const c_char, *const OpaquePtr) -> c_void,
  pub release: extern "C" fn(*const OpaquePtr) -> c_void,
  pub dynamic_to: extern "C" fn(*const OpaquePtr, type_: ElementAttributesType) -> RustValue<c_void>,
}
pub struct ElementAttributes {
  pub ptr: *const OpaquePtr,
  context: *const ExecutingContext,
  method_pointer: *const ElementAttributesRustMethods,
  status: *const RustValueStatus
}
impl ElementAttributes {
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const ElementAttributesRustMethods, status: *const RustValueStatus) -> ElementAttributes {
    ElementAttributes {
      ptr,
      context,
      method_pointer,
      status
    }
  }
  pub fn ptr(&self) -> *const OpaquePtr {
    self.ptr
  }
  pub fn context<'a>(&self) -> &'a ExecutingContext {
    assert!(!self.context.is_null(), "Context PTR must not be null");
    unsafe { &*self.context }
  }
  pub fn get_attribute(&self, name: &str, exception_state: &ExceptionState) -> Result<String, String> {
    let value = unsafe {
      ((*self.method_pointer).get_attribute)(self.ptr(), CString::new(name).unwrap().as_ptr(), exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }
    Ok(value.to_string())
  }
  pub fn set_attribute(&self, name: &str, value: &str, exception_state: &ExceptionState) -> Result<(), String> {
    unsafe {
      ((*self.method_pointer).set_attribute)(self.ptr(), CString::new(name).unwrap().as_ptr(), CString::new(value).unwrap().as_ptr(), exception_state.ptr);
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }
    Ok(())
  }
  pub fn has_attribute(&self, name: &str, exception_state: &ExceptionState) -> Result<bool, String> {
    let value = unsafe {
      ((*self.method_pointer).has_attribute)(self.ptr(), CString::new(name).unwrap().as_ptr(), exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }
    Ok(value != 0)
  }
  pub fn remove_attribute(&self, name: &str, exception_state: &ExceptionState) -> Result<(), String> {
    unsafe {
      ((*self.method_pointer).remove_attribute)(self.ptr(), CString::new(name).unwrap().as_ptr(), exception_state.ptr);
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }
    Ok(())
  }
}
impl Drop for ElementAttributes {
  fn drop(&mut self) {
    unsafe {
      ((*self.method_pointer).release)(self.ptr());
    }
  }
}
pub trait ElementAttributesMethods {
  fn get_attribute(&self, name: &str, exception_state: &ExceptionState) -> Result<String, String>;
  fn set_attribute(&self, name: &str, value: &str, exception_state: &ExceptionState) -> Result<(), String>;
  fn has_attribute(&self, name: &str, exception_state: &ExceptionState) -> Result<bool, String>;
  fn remove_attribute(&self, name: &str, exception_state: &ExceptionState) -> Result<(), String>;
  fn as_element_attributes(&self) -> &ElementAttributes;
}
impl ElementAttributesMethods for ElementAttributes {
  fn get_attribute(&self, name: &str, exception_state: &ExceptionState) -> Result<String, String> {
    self.get_attribute(name, exception_state)
  }
  fn set_attribute(&self, name: &str, value: &str, exception_state: &ExceptionState) -> Result<(), String> {
    self.set_attribute(name, value, exception_state)
  }
  fn has_attribute(&self, name: &str, exception_state: &ExceptionState) -> Result<bool, String> {
    self.has_attribute(name, exception_state)
  }
  fn remove_attribute(&self, name: &str, exception_state: &ExceptionState) -> Result<(), String> {
    self.remove_attribute(name, exception_state)
  }
  fn as_element_attributes(&self) -> &ElementAttributes {
    self
  }
}
