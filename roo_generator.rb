module Rails
  module Generators
    class RooGenerator < NamedBase #metagenerator
      argument :attributes, :type => :array, :default => [], :banner => "model ..."

      def self.assert_model
        raise "model does not exist: #{ARGV[0]}" unless model_class
      end

      def self.assert_no_field
        field = ARGV[1, 100].detect{|a| a =~ /\:/}
        raise "no field given" unless field
        field_sym = field.sub(/\:.*$/, "").to_sym
        begin
          raise "field '#{field_sym}' already exists for model '#{model_class}'" if model_class && model_class.new.respond_to?(field_sym)
        rescue
        end
      end

      def self.assert_field
        field = ARGV[1, 100].detect{|a| a =~ /\:/}
        raise "no field given" unless field
        field_sym = field.sub(/\:.*$/, "").to_sym
        begin
          raise "field '#{field_sym}' missing in model '#{model_class}'" if model_class && !model_class.new.respond_to?(field_sym)
        rescue
        end
      end
        
      def self.model_class
        return unless ARGV[0]
        require ARGV[0].singularize
        class_name = ARGV[0].singularize.camelize.to_s

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

      p ARGV
      action = ARGV[0]
      ARGV.shift
      case action
      when "new_model"
        hook_for :roo_new_model, :default => 'model'
      when "add_field"
        assert_model
        assert_no_field
        index = ARGV[1, 100].select{|a| a =~ /\:/}.collect{ |a| a.sub(/\:.*/, '') }.join("_and_")
        ARGV[0].replace("add_#{index}_to_#{ARGV[0]}")
        hook_for :roo_add_field, :default => 'migration'
      when "remove_field"
        assert_model
        assert_field
        index = ARGV[1, 100].select{|a| a =~ /\:/}.collect{ |a| a.sub(/\:.*/, '') }.join("_and_")
        ARGV[0].replace("remove_#{index}_from_#{ARGV[0]}")
        hook_for :roo_remove_field, :default => 'migration'
      when "rename_field"
        assert_model
        ARGV[1,100].each { |a| a.sub!(/$/, ":dummy") if a =~ /^[a-zA-Z_]+$/ }
        assert_field
        index = ARGV[1, 100].detect{|a| a =~ /\:/}.sub(/\:.*/, '')
        ARGV[0].replace("rename_#{index}_from_#{ARGV[0]}")
        hook_for :roo_rename_field, :default => 'roo_rename'
      else
        argument :attributes, :type => :array, :default => [], :banner => "model] ...\n\nPossible names:\n  [new_model add_field rename_field change_field remove_field destroy_model"
        warn ""
      end
    end
  end
end
