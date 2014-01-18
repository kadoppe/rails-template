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
end

gem_group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'spring'
end

run_bundle

remove_file 'public/index.html'
remove_dir 'test'

run 'bundle exec spring binstub --all'

# rspec
generate 'rspec:install'

git :init
git add: '.'
git commit: "-m 'Initial commit'"
