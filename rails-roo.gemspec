# create by maven - leave it as is
Gem::Specification.new do |s|
  s.name = 'rails-roo'
  s.version = '0.1.0'

  s.summary = 'roo like generators for rails'
  s.description = 'this is inspired by www.springsource.org/roo which allows to manage models and their views during the whole lifecycle of the related classes/files.'
  s.homepage = 'http://github.com/mkristian/rails-roo'

  s.authors = ['mkristian']
  s.email = ['m.kristian@web.de']

  s.files = Dir['MIT-LICENSE']
  s.licenses << 'MIT-LICENSE'
#  s.files += Dir['History.txt']
  s.files += Dir['README.textile']
#  s.extra_rdoc_files = ['History.txt','README.textile']
  s.rdoc_options = ['--main','README.textile']
  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.test_files += Dir['spec/**/*_spec.rb']
  s.add_dependency 'rails', '~> 3.0.0'
  s.add_development_dependency 'rspec', '~> 1.3.0'
  s.add_development_dependency 'rake', '0.8.7'
end
