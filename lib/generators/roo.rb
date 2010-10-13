require 'rails/generators'
require 'rails/generators/active_record'
require 'rails/generators/active_record/migration/migration_generator'
require 'generators/active_record/validations_file'
module Roo
  module Generators
    class Base < ::ActiveRecord::Generators::Base
      arguments.clear # clear name argument from NamedBase
      argument :model, :type => :string, :required => true, :banner => "model"
      def name # set alias so NamedBase uses the model as its name
        @model.replace(@model.singularize)
      end

      def self.parameters_argument
        argument :parameters, :type => :hash, :default => {}, :banner => "index:name index:true unique:true min:123 max:128 presence:false default:blablub"
      end

      def self.migration_exists?(dirname, file_name)
        nil # TODO use option to define behaviour
      end

      def self.model_class(name = ARGV[0])
        return unless name
        begin
          require name.singularize.underscore
        rescue LoadError
          raise "model '#{name}' does not exists"
        end
        class_name = name.singularize.camelize.to_s

        # Split the class from its module nesting
        nesting = class_name.split('::')
        last_name = nesting.pop
        
        # Hack to limit const_defined? to non-inherited on 1.9
        extra = []
        extra << false unless Object.method(:const_defined?).arity == 1
        
        # Extract the last Module in the nesting
        last = nesting.inject(Object) do |last, nest|
          break unless last.const_defined?(nest, *extra)
          last.const_get(nest)
        end
        if last && last.const_defined?(last_name.camelize, *extra)
          last.const_get(last_name.camelize)
        end
      end

      protected

      attr_reader :migration_action, :migration_alternate_action, :new_field, :new_column_options, :old_field, :old_column_options, :new_index_options, :old_index_options

      def add_source_root(reference = __FILE__)
        self.class.source_root(File.join(File.dirname(reference), "templates"))
      end

      def verify_field_exists(field)
        field_sym = field.to_sym
        begin
          raise "field '#{field_sym}' does not exist for model '#{self.class.model_class}'" if self.class.model_class && !self.class.model_class.new.respond_to?(field_sym)
        rescue ::ActiveRecord::ActiveRecordError
          # assume the field is missing
          raise "field '#{field_sym}' does not exist for model '#{self.class.model_class}'"
        end
      end

      def verify_field_missing(field)
        field_sym = field.to_sym
        begin
          raise "field '#{field_sym}' already exists for model '#{self.class.model_class}'" if self.class.model_class && self.class.model_class.new.respond_to?(field_sym)
        rescue ::ActiveRecord::ActiveRecordError
          # assume the field is missing
        end
      end

      def init_old_column_options(name)
        column = self.class.model_class.columns.detect { |c| c.name == name }
        raise "column '#{name}' does not exist" if column.nil?

        @old_field = Rails::Generators::GeneratedAttribute.new(column.name, column.type)
        @old_column_options = {}
        @old_column_options[:limit] = column.limit if column.limit
        @old_column_options[:default] = column.default if column.default
        @old_column_options[:null] = column.null if column.null
        #TODO precision + scale for decimal
      end

      def init_new_column_options(field)
        @new_field = Rails::Generators::GeneratedAttribute.new(field.sub(/\:.*/, ''), field.sub(/.*\:/, ''))
        @new_column_options = {}
        @parameters ||= {}
        @new_column_options[:limit] = @parameters["max"] if @parameters["max"] && @parameters["max"].to_i > 0
        @new_column_options[:default] = @parameters["default"]if @parameters["default"] && @parameters["default"] != ''
        @new_column_options[:null] = "true" != @parameters["presence"] 
        #TODO precision + scale for decimal
      end

      def init_old_index_options
        @old_index_options = nil
      end

      def init_new_index_options
        @new_index_options = {}
        unless @parameters["unique"].nil?
          @new_index_options[:unique] = @parameters["unique"] if @parameters["unique"] == 'true'
        end
        if @parameters["index"].is_a?(String) && (@parameters["index"] =~ /(true|false)/).nil?
          @new_index_options[:name] = @parameters["index"]
        elsif @parameters["index"] != "true" && @new_index_options.size == 0
          @new_index_options = nil
        end
      end

      def rewrite_validations_file(remove = false)
        orm = Rails.application.config.generators.options[:rails][:orm]
        val = Roo.const_get(orm.to_s.camelize.constantize.to_s)::ValidationsFile.new(self.class.model_class(self.class.model_class.to_s + "Validation"))
        if remove
          val.remove(@new_field.name)
        else 
          if @new_fieldname && @old_fieldname
            val.rename(@new_fieldname, @old_fieldname) 
          elsif @parameters
            val.length(@new_field.name, @parameters["min"], @parameters["max"])
            val.presence(@new_field.name, @parameters["presence"])
            val.unique(@new_field.name, @parameters["unique"])
            val.format(@new_field.name, @parameters["format"])
            val.numerical(@new_field.name, @new_field.type)
          end
        end
        file = val.dump(File.join('app', 'models', class_path))
        log "rewrite", file
      end

      def create_roo_migration_file(action, name_middle, alternate_action = nil)
        @migration_action = action
        @migration_alternate_action = alternate_action ? alternate_action : action
        @table_name = @model.pluralize

        # remove the restriction of migration to allow serveral files with the
        # same postfix
        name = "#{action}_#{name_middle}_#{action == 'add'? "to" : "from"}_#{file_name.pluralize}"
        count = Dir.glob("db/migrate/*_#{name}_*.rb").size
        
        migration_template "migration.rb", "db/migrate/#{name}_#{count}.rb"
      end 
    end
  end
end
