// Generated by WebF TSDL, don't edit this file directly.
// Generate command: node scripts/generate_binding_code.js
/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::*;
use crate::*;
#[repr(C)]
pub struct HybridRouterChangeEventRustMethods {
  pub version: c_double,
  pub event: EventRustMethods,
  pub state: extern "C" fn(*const OpaquePtr, *const OpaquePtr) -> NativeValue,
  pub kind: extern "C" fn(*const OpaquePtr) -> AtomicStringRef,
  pub name: extern "C" fn(*const OpaquePtr) -> AtomicStringRef,
}
pub struct HybridRouterChangeEvent {
  pub event: Event,
  method_pointer: *const HybridRouterChangeEventRustMethods,
}
impl HybridRouterChangeEvent {
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const HybridRouterChangeEventRustMethods, status: *const RustValueStatus) -> HybridRouterChangeEvent {
    unsafe {
      HybridRouterChangeEvent {
        event: Event::initialize(
          ptr,
          context,
          &(method_pointer).as_ref().unwrap().event,
          status,
        ),
        method_pointer,
      }
    }
  }
  pub fn ptr(&self) -> *const OpaquePtr {
    self.event.ptr()
  }
  pub fn context<'a>(&self) -> &'a ExecutingContext {
    self.event.context()
  }
  pub fn state(&self, exception_state: &ExceptionState) -> NativeValue {
    let value = unsafe {
      ((*self.method_pointer).state)(self.ptr(), exception_state.ptr)
    };
    value
  }
  pub fn kind(&self) -> String {
    let value = unsafe {
      ((*self.method_pointer).kind)(self.ptr())
    };
    value.to_string()
  }
  pub fn name(&self) -> String {
    let value = unsafe {
      ((*self.method_pointer).name)(self.ptr())
    };
    value.to_string()
  }
}
pub trait HybridRouterChangeEventMethods: EventMethods {
  fn state(&self, exception_state: &ExceptionState) -> NativeValue;
  fn kind(&self) -> String;
  fn name(&self) -> String;
  fn as_hybrid_router_change_event(&self) -> &HybridRouterChangeEvent;
}
impl HybridRouterChangeEventMethods for HybridRouterChangeEvent {
  fn state(&self, exception_state: &ExceptionState) -> NativeValue {
    self.state(exception_state)
  }
  fn kind(&self) -> String {
    self.kind()
  }
  fn name(&self) -> String {
    self.name()
  }
  fn as_hybrid_router_change_event(&self) -> &HybridRouterChangeEvent {
    self
  }
}
impl EventMethods for HybridRouterChangeEvent {
  fn bubbles(&self) -> bool {
    self.event.bubbles()
  }
  fn cancel_bubble(&self) -> bool {
    self.event.cancel_bubble()
  }
  fn set_cancel_bubble(&self, value: bool, exception_state: &ExceptionState) -> Result<(), String> {
    self.event.set_cancel_bubble(value, exception_state)
  }
  fn cancelable(&self) -> bool {
    self.event.cancelable()
  }
  fn current_target(&self) -> EventTarget {
    self.event.current_target()
  }
  fn default_prevented(&self) -> bool {
    self.event.default_prevented()
  }
  fn src_element(&self) -> EventTarget {
    self.event.src_element()
  }
  fn target(&self) -> EventTarget {
    self.event.target()
  }
  fn is_trusted(&self) -> bool {
    self.event.is_trusted()
  }
  fn time_stamp(&self) -> f64 {
    self.event.time_stamp()
  }
  fn type_(&self) -> String {
    self.event.type_()
  }
  fn init_event(&self, type_: &str, bubbles: bool, cancelable: bool, exception_state: &ExceptionState) -> Result<(), String> {
    self.event.init_event(type_, bubbles, cancelable, exception_state)
  }
  fn prevent_default(&self, exception_state: &ExceptionState) -> Result<(), String> {
    self.event.prevent_default(exception_state)
  }
  fn stop_immediate_propagation(&self, exception_state: &ExceptionState) -> Result<(), String> {
    self.event.stop_immediate_propagation(exception_state)
  }
  fn stop_propagation(&self, exception_state: &ExceptionState) -> Result<(), String> {
    self.event.stop_propagation(exception_state)
  }
  fn as_event(&self) -> &Event {
    &self.event
  }
}
impl ExecutingContext {
  pub fn create_hybrid_router_change_event(&self, exception_state: &ExceptionState) -> Result<HybridRouterChangeEvent, String> {
    let new_obj = unsafe {
      ((*self.method_pointer()).create_hybrid_router_change_event)(self.ptr, exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self));
    }
    return Ok(HybridRouterChangeEvent::initialize(new_obj.value, self, new_obj.method_pointer, new_obj.status));
  }
}
