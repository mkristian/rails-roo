require 'rails/generators/active_record'
require 'rails/generators/active_record/migration/migration_generator'
require 'generators/roo'

module Roo
  module Generators
    class RenameFieldGenerator < Roo::Generators::Base
      
      argument :old_fieldname, :type => :string, :required => true, :banner => "old_fieldname"
      argument :new_fieldname, :type => :string, :required => true, :banner => "new_fieldname"

      attr_reader :old_fieldname, :new_fieldname

      def create_migration_file
        verify_field_exists(@old_fieldname)
        add_source_root(__FILE__)
        create_roo_migration_file("rename", @old_fieldname)
        rewrite_validations_file
      end
    end
  end
end
