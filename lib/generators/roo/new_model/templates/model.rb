class <%= class_name %> < <%= parent_class_name.classify %>

<% if options[:validation] || true -%>
  include <%= class_name %>Validation
<% end -%>
<% attributes.select {|attr| attr.reference? }.each do |attribute| -%>
  belongs_to :<%= attribute.name %>
<% end -%>

end
