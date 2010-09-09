require 'rails/generators/active_record'
require 'rails/generators/active_record/migration/migration_generator'
require 'roo/base'

module Roo
  module Generators
    class ChangeFieldGenerator < Roo::Generators::Base
      
      argument :field, :type => :string, :required => true, :banner => "field:type"

      parameters_argument

      attr_reader :new_field, :new_column_options, :old_field, :old_column_options, :index_options

      def create_migration_file
        add_source_root
        init_new_column_options(@field)
        verify_field_exists(@new_field.name)
        init_old_column_options(@new_field.name)
        init_new_index_options
        init_old_index_options
        create_roo_migration_file("change", @new_field.name)
        rewrite_validations_file
      end
    end
  end
end
