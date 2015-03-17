repo_url = 'https://raw.github.com/kadoppe/rails-template/master'

gem_group :default do
  gem 'active-decorator'
  gem 'bootstrap-sass'
  gem 'bootswatch-rails'
  gem 'font-awesome-rails'
  gem 'slim-rails'
end

gem_group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'meta_request'
end

gem_group :development, :test do
  gem 'awesome_print', require: 'ap'
  gem 'byebug'
  gem 'factory_girl_rails'
  gem 'guard'
  gem 'hirb'
  gem 'hirb-unicode'
  gem 'pry-byebug'
  gem 'pry-coolline'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'rails-flog'
  gem 'rspec-rails'
  gem 'spring'
  gem 'sqlite3'
  gem 'web-console', '~> 2.0'
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
end

run 'bundle install --path vendor/bundle --jobs=4'

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
