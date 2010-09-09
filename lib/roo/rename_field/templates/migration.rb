class <%= migration_class_name %> < ActiveRecord::Migration
  def self.up
  <%- if migration_action -%>
    <%= migration_action %>_column :<%= table_name %>, :<%= old_fieldname %>, :<%= new_fieldname %>
  <%- end -%>
  end

  def self.down
  <%- if migration_action -%>
    <%= migration_action %>_column :<%= table_name %>, :<%= new_fieldname %>, :<%= old_fieldname %>
  <%- end -%>
  end
end
