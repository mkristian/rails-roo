require 'rails/generators/active_record'
require 'rails/generators/active_record/migration/migration_generator'
require 'generators/roo'
require 'rails/generators/test_unit'

module Roo
  module Generators
    class NewModelGenerator < Roo::Generators::Base

      source_root(File.join(File.dirname(__FILE__), "templates"))

      check_class_collision

      class_option :validation,  :type => :boolean
      class_option :timestamps,  :type => :boolean
      class_option :parent,     :type => :string, :desc => "The parent class for the generated model"

      def create_migration_file
        return unless options[:parent].nil?
        create_file File.join('app', 'models', class_path, file_name) + "_validation.rb", "module #{class_name}Validation; end"

        unless f = Dir.glob("db/migrate/*_create_#{table_name}.rb")[0]
          migration_template "migration.rb", "db/migrate/create_#{table_name}.rb"
        else
          say_status :identical, f, :blue
        end
      end

      def attributes
        []
      end
      def attributes=(*args)
        []
      end

      def create_model_file
        template 'model.rb', File.join('app/models', class_path, "#{file_name}.rb")
      end

      def create_module_file
        return if class_path.empty?
        template 'module.rb', File.join('app/models', "#{class_path.join('/')}.rb") if behavior == :invoke
      end

      hook_for :test_framework, :as => :model

      protected

      def parent_class_name
        options[:parent] || "ActiveRecord::Base"
      end

    end
  end
end
