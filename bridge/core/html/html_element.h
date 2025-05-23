/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_HTML_HTML_ELEMENT_H_
#define BRIDGE_CORE_HTML_HTML_ELEMENT_H_

#include "core/dom/element.h"
#include "core/dom/global_event_handlers.h"
#include "plugin_api_gen/html_element.h"

namespace webf {

class HTMLElement : public Element {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLElement*;
  HTMLElement(const AtomicString& tag_name, Document* document, ConstructionType = kCreateHTMLElement);

  const HTMLElementPublicMethods* htmlElementPublicMethods() {
    static HTMLElementPublicMethods html_element_public_methods;
    return &html_element_public_methods;
  }

 private:
};

template <typename T>
bool IsElementOfType(const HTMLElement&);
template <>
inline bool IsElementOfType<const HTMLElement>(const HTMLElement&) {
  return true;
}
template <>
inline bool IsElementOfType<const HTMLElement>(const Node& node) {
  return IsA<HTMLElement>(node);
}
template <>
struct DowncastTraits<HTMLElement> {
  static bool AllowFrom(const Node& node) { return node.IsHTMLElement(); }
  static bool AllowFrom(const EventTarget& event_target) {
    return event_target.IsNode() && To<Node>(event_target).IsHTMLElement();
  }
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_HTML_ELEMENT_H_
