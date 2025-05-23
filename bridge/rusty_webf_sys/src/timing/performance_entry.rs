// Generated by WebF TSDL, don't edit this file directly.
// Generate command: node scripts/generate_binding_code.js
/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::*;
use crate::*;
#[repr(C)]
enum PerformanceEntryType {
  PerformanceEntry = 0,
  PerformanceMeasure = 1,
  PerformanceMark = 2,
}
#[repr(C)]
pub struct PerformanceEntryRustMethods {
  pub version: c_double,
  pub name: extern "C" fn(*const OpaquePtr) -> AtomicStringRef,
  pub entry_type: extern "C" fn(*const OpaquePtr) -> AtomicStringRef,
  pub start_time: extern "C" fn(*const OpaquePtr) -> i64,
  pub duration: extern "C" fn(*const OpaquePtr) -> i64,
  pub to_json: extern "C" fn(*const OpaquePtr, *const OpaquePtr) -> NativeValue,
  pub release: extern "C" fn(*const OpaquePtr) -> c_void,
  pub dynamic_to: extern "C" fn(*const OpaquePtr, type_: PerformanceEntryType) -> RustValue<c_void>,
}
pub struct PerformanceEntry {
  pub ptr: *const OpaquePtr,
  context: *const ExecutingContext,
  method_pointer: *const PerformanceEntryRustMethods,
  status: *const RustValueStatus
}
impl PerformanceEntry {
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const PerformanceEntryRustMethods, status: *const RustValueStatus) -> PerformanceEntry {
    PerformanceEntry {
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
  pub fn name(&self) -> String {
    let value = unsafe {
      ((*self.method_pointer).name)(self.ptr())
    };
    value.to_string()
  }
  pub fn entry_type(&self) -> String {
    let value = unsafe {
      ((*self.method_pointer).entry_type)(self.ptr())
    };
    value.to_string()
  }
  pub fn start_time(&self) -> i64 {
    let value = unsafe {
      ((*self.method_pointer).start_time)(self.ptr())
    };
    value
  }
  pub fn duration(&self) -> i64 {
    let value = unsafe {
      ((*self.method_pointer).duration)(self.ptr())
    };
    value
  }
  pub fn to_json(&self, exception_state: &ExceptionState) -> Result<NativeValue, String> {
    let value = unsafe {
      ((*self.method_pointer).to_json)(self.ptr(), exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }
    Ok(value)
  }
  pub fn as_performance_measure(&self) -> Result<PerformanceMeasure, &str> {
    let raw_ptr = unsafe {
      assert!(!(*((*self).status)).disposed, "The underline C++ impl of this ptr({:?}) had been disposed", (self.method_pointer));
      ((*self.method_pointer).dynamic_to)(self.ptr, PerformanceEntryType::PerformanceMeasure)
    };
    if (raw_ptr.value == std::ptr::null()) {
      return Err("The type value of PerformanceEntry does not belong to the PerformanceMeasure type.");
    }
    Ok(PerformanceMeasure::initialize(raw_ptr.value, self.context, raw_ptr.method_pointer as *const PerformanceMeasureRustMethods, raw_ptr.status))
  }
  pub fn as_performance_mark(&self) -> Result<PerformanceMark, &str> {
    let raw_ptr = unsafe {
      assert!(!(*((*self).status)).disposed, "The underline C++ impl of this ptr({:?}) had been disposed", (self.method_pointer));
      ((*self.method_pointer).dynamic_to)(self.ptr, PerformanceEntryType::PerformanceMark)
    };
    if (raw_ptr.value == std::ptr::null()) {
      return Err("The type value of PerformanceEntry does not belong to the PerformanceMark type.");
    }
    Ok(PerformanceMark::initialize(raw_ptr.value, self.context, raw_ptr.method_pointer as *const PerformanceMarkRustMethods, raw_ptr.status))
  }
}
impl Drop for PerformanceEntry {
  fn drop(&mut self) {
    unsafe {
      ((*self.method_pointer).release)(self.ptr());
    }
  }
}
pub trait PerformanceEntryMethods {
  fn name(&self) -> String;
  fn entry_type(&self) -> String;
  fn start_time(&self) -> i64;
  fn duration(&self) -> i64;
  fn to_json(&self, exception_state: &ExceptionState) -> Result<NativeValue, String>;
  fn as_performance_entry(&self) -> &PerformanceEntry;
}
impl PerformanceEntryMethods for PerformanceEntry {
  fn name(&self) -> String {
    self.name()
  }
  fn entry_type(&self) -> String {
    self.entry_type()
  }
  fn start_time(&self) -> i64 {
    self.start_time()
  }
  fn duration(&self) -> i64 {
    self.duration()
  }
  fn to_json(&self, exception_state: &ExceptionState) -> Result<NativeValue, String> {
    self.to_json(exception_state)
  }
  fn as_performance_entry(&self) -> &PerformanceEntry {
    self
  }
}
