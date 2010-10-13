apply File.join(File.dirname(__FILE__), 'roo-template.rb')

def rake(*args)
  ruby = (defined? JRUBY_VERSION) ? "jruby" : "ruby"
  run "#{ruby} -S rake #{args.join(' ')}"
end

def roo_generate(*args)
  generate *args
  rake "db:migrate"
end

roo_generate 'roo:new_model', 'user'

roo_generate 'roo:add_field', 'user', "name:string"

roo_generate 'roo:rename_field', 'user', "name", "login"

roo_generate 'roo:change_field', 'user', "login:string", "presence:true", "max:124"

roo_generate 'roo:change_field', 'user', "login:string", "presence:true", "min:12", "max:224"

roo_generate 'roo:change_field', 'user', "login:string", "presence:true", "min:2", "max:24", "default:bka"

roo_generate 'roo:change_field', 'user', "login:string", "presence:true", "min:2", "max:24", "default:bka"

roo_generate 'roo:change_field', 'user', "login:string", "presence:true", "min:2", "max:24", "default:bka", "unique:true", "format:[a-z]*"

roo_generate 'roo:add_field', 'user', "name:string"

roo_generate 'roo:remove_field', 'user', "name"

rake "db:migrate VERSION=0"

rake "db:migrate"

