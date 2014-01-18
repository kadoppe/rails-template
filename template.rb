repo_url = 'https://raw.github.com/kadoppe/rails-template/master'

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

# rspec
generate 'rspec:install'

insert_into_file 'spec/spec_helper.rb',
  "require 'factory_girl'\n",
  after: "require 'rspec/autorun'\n"
insert_into_file 'spec/spec_helper.rb',
  "  config.include FactoryGirl::Syntax::Methods\n",
  after: "RSpec.configure do |config|\n"
insert_into_file 'spec/spec_helper.rb', <<-CONFIG, after: %(config.order = "random"\n)
  config.before(:all) do
    FactoryGirl.reload
  end
CONFIG

run 'bundle exec spring binstub --all'

git :init
git add: '.'
git commit: "-m 'Initial commit'"
