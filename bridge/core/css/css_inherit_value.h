/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2008 Apple Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

#ifndef WEBF_CORE_CSS_CSS_INHERIT_VALUE_H_
#define WEBF_CORE_CSS_CSS_INHERIT_VALUE_H_

#include "core/css/css_value.h"

namespace webf {

class CSSInheritedValue : public CSSValue {
 public:
  static std::shared_ptr<const CSSInheritedValue> Create();

  // Only construct through MakeGarbageCollected for the initial value. Use
  // Create() to get the pooled value.
  CSSInheritedValue() : CSSValue(kInheritedClass) {}

  std::string CustomCSSText() const;

  bool Equals(const CSSInheritedValue&) const { return true; }

  void TraceAfterDispatch(GCVisitor* visitor) const { CSSValue::TraceAfterDispatch(visitor); }

 private:
  friend class CSSValuePool;
};

template <>
struct DowncastTraits<CSSInheritedValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsInheritedValue(); }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_INHERIT_VALUE_H_
