// Generated from template:
//   code_generator/src/json/templates/make_names.h.tmpl
// and input files:
//   <%= template_path %>


#ifndef <%= _.snakeCase(name).toUpperCase() %>_H_
#define <%= _.snakeCase(name).toUpperCase() %>_H_

#include "foundation/atomic_string.h"

namespace webf {
namespace <%= name %> {

<% _.forEach(data, function(name, index) { %>
  <% if (_.isArray(name)) { %>
    extern thread_local const AtomicString& k<%= options.camelcase ? upperCamelCase(name[0]) : name[0] %>;
  <% } else if (_.isObject(name)) { %>
    extern thread_local const AtomicString& k<%= options.camelcase ? upperCamelCase(name.name) : name.name %>;
  <% } else { %>
  extern thread_local const AtomicString& k<%= options.camelcase ? upperCamelCase(name) : name %>;
  <% } %>
<% }) %>

<% if (deps && deps.html_attribute_names) { %>
  constexpr unsigned kHtmlAttributeNamesCount = <%= deps.html_attribute_names.data.length %>;
  <% _.forEach(deps.html_attribute_names.data, function(name, index) { %>
    extern thread_local const AtomicString& k<%= upperCamelCase(name) %>Attr;
  <% }) %>
<% } %>

constexpr unsigned kNamesCount = <%= data.length %>;

void Init();
void Dispose();

}

} // webf

#endif  // #define <%= _.snakeCase(name).toUpperCase() %>
