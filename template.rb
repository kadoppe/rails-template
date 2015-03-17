repo_url = 'https://raw.github.com/kadoppe/rails-template/master'

# .gitignore
run 'gibo OSX Ruby Rails > .gitignore' rescue nil

# Gemfile
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
  gem 'html2slim'
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

# install gems
run 'bundle install --path vendor/bundle --jobs=4'

# config/application.rb
application do
  %q{
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    I18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja

    config.generators do |g|
      g.orm :active_record
      g.template_engine :slim
      g.test_framework :rspec, :fixture => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
      g.view_specs false
      g.controller_specs true
      g.routing_specs false
      g.helper_specs false
      g.request_specs false
      g.assets false
      g.helper false
    end

    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
  }
end

# bullet
insert_into_file 'config/environments/development.rb', %(
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
  end
), after: 'config.assets.debug = true'

# convert erb file to slim
run 'bundle exec erb2slim -d app/views'


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
