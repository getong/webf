// Generated by WebF TSDL, don't edit this file directly.
// Generate command: node scripts/generate_binding_code.js
/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::*;
use crate::*;
#[repr(C)]
pub struct MessageEventRustMethods {
  pub version: c_double,
  pub event: EventRustMethods,
  pub data: extern "C" fn(*const OpaquePtr, *const OpaquePtr) -> NativeValue,
  pub origin: extern "C" fn(*const OpaquePtr) -> AtomicStringRef,
  pub last_event_id: extern "C" fn(*const OpaquePtr) -> AtomicStringRef,
  pub source: extern "C" fn(*const OpaquePtr) -> AtomicStringRef,
}
pub struct MessageEvent {
  pub event: Event,
  method_pointer: *const MessageEventRustMethods,
}
impl MessageEvent {
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const MessageEventRustMethods, status: *const RustValueStatus) -> MessageEvent {
    unsafe {
      MessageEvent {
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
  pub fn data(&self, exception_state: &ExceptionState) -> NativeValue {
    let value = unsafe {
      ((*self.method_pointer).data)(self.ptr(), exception_state.ptr)
    };
    value
  }
  pub fn origin(&self) -> String {
    let value = unsafe {
      ((*self.method_pointer).origin)(self.ptr())
    };
    value.to_string()
  }
  pub fn last_event_id(&self) -> String {
    let value = unsafe {
      ((*self.method_pointer).last_event_id)(self.ptr())
    };
    value.to_string()
  }
  pub fn source(&self) -> String {
    let value = unsafe {
      ((*self.method_pointer).source)(self.ptr())
    };
    value.to_string()
  }
}
pub trait MessageEventMethods: EventMethods {
  fn data(&self, exception_state: &ExceptionState) -> NativeValue;
  fn origin(&self) -> String;
  fn last_event_id(&self) -> String;
  fn source(&self) -> String;
  fn as_message_event(&self) -> &MessageEvent;
}
impl MessageEventMethods for MessageEvent {
  fn data(&self, exception_state: &ExceptionState) -> NativeValue {
    self.data(exception_state)
  }
  fn origin(&self) -> String {
    self.origin()
  }
  fn last_event_id(&self) -> String {
    self.last_event_id()
  }
  fn source(&self) -> String {
    self.source()
  }
  fn as_message_event(&self) -> &MessageEvent {
    self
  }
}
impl EventMethods for MessageEvent {
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
  pub fn create_message_event(&self, event_type: &str, exception_state: &ExceptionState) -> Result<MessageEvent, String> {
    let event_type_c_string = CString::new(event_type).unwrap();
    let new_event = unsafe {
      ((*self.method_pointer()).create_message_event)(self.ptr, event_type_c_string.as_ptr(), exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self));
    }
    return Ok(MessageEvent::initialize(new_event.value, self, new_event.method_pointer, new_event.status));
  }
  pub fn create_message_event_with_options(&self, event_type: &str, options: &MessageEventInit,  exception_state: &ExceptionState) -> Result<MessageEvent, String> {
    let event_type_c_string = CString::new(event_type).unwrap();
    let new_event = unsafe {
      ((*self.method_pointer()).create_message_event_with_options)(self.ptr, event_type_c_string.as_ptr(), options, exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self));
    }
    return Ok(MessageEvent::initialize(new_event.value, self, new_event.method_pointer, new_event.status));
  }
}
