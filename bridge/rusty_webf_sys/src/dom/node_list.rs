// Generated by WebF TSDL, don't edit this file directly.
// Generate command: node scripts/generate_binding_code.js
/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::*;
use crate::*;
#[repr(C)]
enum NodeListType {
  NodeList = 0,
}
#[repr(C)]
pub struct NodeListRustMethods {
  pub version: c_double,
  pub length: extern "C" fn(*const OpaquePtr) -> i64,
  pub item: extern "C" fn(*const OpaquePtr, c_double, *const OpaquePtr) -> RustValue<NodeRustMethods>,
  pub release: extern "C" fn(*const OpaquePtr) -> c_void,
  pub dynamic_to: extern "C" fn(*const OpaquePtr, type_: NodeListType) -> RustValue<c_void>,
}
pub struct NodeList {
  pub ptr: *const OpaquePtr,
  context: *const ExecutingContext,
  method_pointer: *const NodeListRustMethods,
  status: *const RustValueStatus
}
impl NodeList {
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const NodeListRustMethods, status: *const RustValueStatus) -> NodeList {
    NodeList {
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
  pub fn length(&self) -> i64 {
    let value = unsafe {
      ((*self.method_pointer).length)(self.ptr())
    };
    value
  }
  pub fn item(&self, index: f64, exception_state: &ExceptionState) -> Result<Node, String> {
    let value = unsafe {
      ((*self.method_pointer).item)(self.ptr(), index, exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }
    Ok(Node::initialize(value.value, self.context(), value.method_pointer, value.status))
  }
}
impl Drop for NodeList {
  fn drop(&mut self) {
    unsafe {
      ((*self.method_pointer).release)(self.ptr());
    }
  }
}
pub trait NodeListMethods {
  fn length(&self) -> i64;
  fn item(&self, index: f64, exception_state: &ExceptionState) -> Result<Node, String>;
  fn as_node_list(&self) -> &NodeList;
}
impl NodeListMethods for NodeList {
  fn length(&self) -> i64 {
    self.length()
  }
  fn item(&self, index: f64, exception_state: &ExceptionState) -> Result<Node, String> {
    self.item(index, exception_state)
  }
  fn as_node_list(&self) -> &NodeList {
    self
  }
}
