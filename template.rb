gem_group :default do
  gem 'slim'
  gem 'slim-rails'
end

gem_group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'hirb'
  gem 'hirb-unicode'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-coolline'
  gem 'pry-rails'
  gem 'request_profiler'
  gem 'simplecov'
  gem 'spring'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'guard'
  gem 'guard-rspec'
  gem 'rspec-rails'
  gem 'spring'
  gem 'terminal-notifier-guard'
end
