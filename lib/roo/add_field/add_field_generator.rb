require 'rails/generators/active_record'
require 'rails/generators/active_record/migration/migration_generator'
require 'roo/base'
require 'roo/active_record/validations_file'

module Roo
  module Generators
    class AddFieldGenerator < Roo::Generators::Base
      
      argument :field, :type => :string, :required => true, :banner => "field:type"

      parameters_argument

      def create_migration_file
        add_source_root
        init_new_column_options(@field)
        verify_field_missing(@new_field.name)
        init_new_index_options
        create_roo_migration_file("add", @new_field.name, "remove")
        rewrite_validations_file
      end
    end
  end
end
