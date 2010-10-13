class <%= migration_class_name %> < ActiveRecord::Migration
  def self.up
  <%- if migration_action -%>
    <%= migration_action %>_column :<%= table_name %>, :<%= new_field.name %><%- if migration_action != 'remove' -%>, :<%= new_field.type %><%- end -%><%- new_column_options.each do |k,v| -%>, :<%= k %> => <%= v.inspect %><%- end -%>
  <%- end -%>
  <%- if old_index_options -%>

    remove_index :<%= table_name %>, :<%= old_field.name %>
  <%- end -%>
  <%- if new_index_options -%>

    add_index :<%= table_name %>, :<%= new_field.name %><%- new_index_options.each do |k,v| -%>, :<%= k %> => <%= v %><%- end -%>
  <%- end -%>

  end

  def self.down
  <%- if migration_alternate_action -%>
    <%= migration_alternate_action %>_column :<%= table_name %>, :<%= new_field.name %><%- if migration_alternate_action != 'remove' -%>, :<%= old_field.type %><%- end -%><%- (old_column_options || {}).each do |k,v| -%>, :<%= k %> => <%= v.inspect %><%- end -%>
  <%- end -%>
  <%- if new_index_options -%>

    remove_index :<%= table_name %>, :<%= new_field.name %>
  <%- end -%>
  <%- if old_index_options -%>

    add_index :<%= table_name %>, :<%= old_field.name %><%- old_index_options.each do |k,v| -%>, :<%= k %> => <%= v %><%- end -%>
  <%- end -%>

  end
end
