require 'rails/generators/active_record'
require 'rails/generators/active_record/migration/migration_generator'
require 'generators/roo'

module Roo
  module Generators
    class RemoveFieldGenerator < Roo::Generators::Base
      
      argument :fieldname, :type => :string, :required => true, :banner => "fieldname"

      def create_migration_file
        add_source_root
        verify_field_exists(@fieldname)
        init_new_column_options("#{@fieldname}:dummy")
        init_old_column_options(@new_field.name)
        init_old_index_options
        create_roo_migration_file("remove", @new_field.name, "add")
        rewrite_validations_file(true)#trigger remove
      end
    end
  end
end
