module Roo
  module ActiveRecord
    class ValidationsFile

      class Field
        
        attr_accessor :name, :validators
        
        def initialize(name)
          @name = name.to_sym
          @validators = {}
        end
        
        def self.get(name)
          name = name.to_sym
          get!(name) || @fields[name] = Field.new(name)
        end
        
        def self.get!(name)
          name = name.to_sym
          @fields ||= {}
          @fields[name]
        end
        
        def self.add(name, field)
          name = name.to_sym
          @fields ||= {}
          @fields[name] = field
        end

        def self.remove(name)
          name = name.to_sym
          @fields ||= {}
          @fields.delete(name)
        end
        
        def self.all
          @fields ||= {}
          @fields.values
        end
        
        def self.clear
          all.clear
        end
        
        def add(validator, args = {})
          validator = @validators[validator.to_sym] ||= {}
          validator.merge!(args)
          validator.delete_if { |k, v| v.nil? }
        end
        
        def remove(validator)
          @validators.delete(validator.to_sym)
        end

        def rename(new_name)
          self.class.remove(@name)
          @name = new_name
          self.class.add(@name, self)
        end
      end
      
      def initialize(module_const)
        self.class.send(:include, module_const)
        @module_const = module_const
      end
      
      def dump(dir)
        parts = @module_const.to_s.split("::")
        parts.each do |part|
          part.replace(part.underscore)
        end
        file = File.join(dir, parts) + ".rb"
        File.open(file, 'w') do |o|
          o.puts("# this file gets modified by rails-roo generators")
          o.puts("# no lamda, block or Proc allowed")
          o.puts("module #{@module_const}")
          o.puts("  def self.included(model)")
          Field.all.each do |f|
            f.validators.each do |k,v|
              o.print("    model.#{k} :#{f.name}")
              if v && v.size > 0
                vv = v.inspect
                vv = vv[1, (vv.size - 2)]
                o.puts(", #{vv}") 
              else
                o.puts
              end
            end
          end
          o.puts("  end")
          o.puts("end")
        end
        file
      end
      
      def self.method_missing(method, *args)
        name = args.shift
        Field.get(name).add(method, *args)
      end

      private
      
      def to_boolean(b)
        (b.is_a?(String) && b.downcase == "true") || b == true
      end

      public

      def remove(name)
        Field.remove(name)
      end
            
      def rename(new_name, old_name)
        if(new_name != old_name)
          Field.get(old_name).rename(new_name)
          true
        else
          false
        end
      end
      
      def unique(name, unique = true)
        if to_boolean(unique)
          Field.get(name).add(:validates_uniqueness_of)
        else
          Field.get(name).remove(:validates_uniqueness_of)
        end
      end
      
      def numerical(name, type)
        return unless type # type is required
        if [:short, :long, :integer, :float, :decimal, :double, :number, :fixnum].member?(type.to_sym)
          Field.get(name).add(:validates_numericality_of)
        else
          Field.get(name).remove(:validates_numericality_of)
        end
      end

      def presence(name, presence = true)
        if to_boolean(presence)
          Field.get(name).add(:validates_presence_of)
        else
          Field.get(name).remove(:validates_presence_of)
        end
      end

      def format(name, format = nil)
        if format
          Field.get(name).add(:validates_format_of, :with => /#{format}/)
        else
          Field.get(name).remove(:validates_format_of)
        end
      end
      
      def length(name, min = nil, max = nil)
        f = Field.get(name)
        min = (min || 0).to_i
        max = (max || 0).to_i
        if min == 0 && max == 0
          f.remove(:validates_length_of)
        else
          f.add(:validates_length_of, :is => nil, :maximum => nil, :minimum => nil, :in => nil, :within => nil, :in => nil)
          if(max == min)
            f.add(:validates_length_of, :is => max)
          else
            f.add(:validates_length_of, :maximum => max) if max && max > 0
            f.add(:validates_length_of, :minimum => min) if min && min > 0
          end
        end
      end
    end
  end
end
