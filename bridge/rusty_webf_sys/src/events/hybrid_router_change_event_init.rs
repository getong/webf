// Generated by WebF TSDL, don't edit this file directly.
// Generate command: node scripts/generate_binding_code.js
/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::*;
use crate::*;
#[repr(C)]
pub struct HybridRouterChangeEventInit {
  pub bubbles: i32,
  pub cancelable: i32,
  pub composed: i32,
  pub kind: *const c_char,
  pub name: *const c_char,
  pub state: NativeValue,
}
