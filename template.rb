empty_line_pattern = /^\s*\n/
comment_line_pattern = /^\s*#.*\n/

# .gitignore
run 'gibo OSX Ruby Rails JetBrains > .gitignore' rescue nil
gsub_file '.gitignore', comment_line_pattern, ''
gsub_file '.gitignore', /^config\/initializers\/secret_token.rb\n/, ''
gsub_file '.gitignore', /^config\/secrets.yml\n/, ''

# Gemfile
gsub_file 'Gemfile', comment_line_pattern, ''
gsub_file 'Gemfile', /gem 'turbolinks'\n/, ''
gsub_file 'Gemfile', /gem 'jquery-rails'\n/, ''

add_source 'https://rails-assets.org'

gem_group :default do
  gem 'active_decorator'
  gem 'slim-rails'
  gem 'rails-assets-bootstrap-sass-official'
  gem 'rails-assets-fontawesome'
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
  gem 'factory_girl_rails'
  gem 'guard'
  gem 'hirb'
  gem 'hirb-unicode'
  gem 'pry-byebug'
  gem 'pry-coolline'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'rspec-rails'
end

gem_group :test do
  gem 'database_rewinder'
  gem 'webmock'
  gem 'vcr'
end

gem_group :production do
  gem 'pg'
  gem 'rails_12factor'
end

# install gems
run 'bundle install --path vendor/bundle --jobs=4'

# install locales
remove_file 'config/locales/en.yml'
run 'wget https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/en.yml -P config/locales/'
run 'wget https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml -P config/locales/'

# config/application.rb
gsub_file 'config/application.rb', comment_line_pattern, ''
application do
  %q{
    config.time_zone = 'Tokyo'

    I18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

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

# config/database.yml
gsub_file 'config/database.yml', comment_line_pattern, ''

# config/environments/development.rb
gsub_file 'config/environments/development.rb', comment_line_pattern, ''
insert_into_file 'config/environments/development.rb', <<RUBY, after: 'config.assets.debug = true'

  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
  end
RUBY

# config/environments/test.rb
gsub_file 'config/environments/test.rb', comment_line_pattern, ''

# config/environments/test.rb
gsub_file 'config/environments/production.rb', comment_line_pattern, ''

# config/initializers/assets.rb
gsub_file 'config/initializers/assets.rb', comment_line_pattern, ''
gsub_file 'config/initializers/assets.rb', empty_line_pattern, ''

# config/initializers/backtrace_silencers.rb
gsub_file 'config/initializers/backtrace_silencers.rb', comment_line_pattern, ''
gsub_file 'config/initializers/backtrace_silencers.rb', empty_line_pattern, ''

# config/initializers/cookies_serializer.rb
gsub_file 'config/initializers/cookies_serializer.rb', comment_line_pattern, ''
gsub_file 'config/initializers/cookies_serializer.rb', empty_line_pattern, ''

# convert erb file to slim
run 'bundle exec erb2slim -d app/views'

# rspec
generate 'rspec:install'
run "echo '--color -f d' > .rspec"

insert_into_file 'spec/spec_helper.rb', %(
require 'factory_girl_rails'
require 'vcr'
), before: 'RSpec.configure do |config|'

insert_into_file 'spec/spec_helper.rb', %(
  config.before :suite do
    DatabaseRewinder.clean_all
  end

  config.after :each do
    DatabaseRewinder.clean
  end

  config.before :all do
    FactoryGirl.reload
    FactoryGirl.factories.clear
    FactoryGirl.sequences.clear
    FactoryGirl.find_definitions
  end

  config.include FactoryGirl::Syntax::Methods

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/vcr'
    c.hook_into :webmock
    c.allow_http_connections_when_no_cassette = true
  end
), after: 'RSpec.configure do |config|'

gsub_file 'spec/spec_helper.rb', "require 'rspec/autorun'", ''

# app/assets/javascripts/application.js
create_file 'app/assets/javascripts/application.js', <<JS, force: true
//= require jquery
//= require bootstrap-sass-official
//= require_tree .
JS

# app/assets/stylesheets/application.css.scss
remove_file 'app/assets/stylesheets/application.css'
create_file 'app/assets/stylesheets/application.css.scss', <<CSS, force: true
/*
 *= require_tree .
 *= require fontawesome
 *= require_self
 */

$icon-font-path: "bootstrap-sass-official/";

@import "bootstrap-sass-official/bootstrap-sprockets";
@import "bootstrap-sass-official/bootstrap";

body { padding-top: 70px; }
CSS

# create layout
create_file 'app/views/layouts/application.html.slim', <<SLIM, force: true
doctype html
html
  head
    title
      | #{app_name}
    = stylesheet_link_tag    'application', media: 'all'
    = csrf_meta_tags
  body
    nav.navbar.navbar-default.navbar-fixed-top
      .container
        .container-header
          a.navbar-brand
            | #{app_name}

    .container
      = yield

    = javascript_include_tag 'application'
SLIM

# create pages controller
generate :controller, 'pages'
create_file 'app/views/pages/index.html.slim', <<SLIM
p Under construction
SLIM

# routes.rb
gsub_file 'config/routes.rb', comment_line_pattern, ''
gsub_file 'config/routes.rb', empty_line_pattern, ''
route "root to: 'pages#index'"

# Rakefile
gsub_file 'Rakefile', comment_line_pattern, ''
gsub_file 'Rakefile', empty_line_pattern, ''

# config.ru
gsub_file 'config.ru', comment_line_pattern, ''
gsub_file 'config.ru', empty_line_pattern, ''

# config/environment.rb
gsub_file 'config/environment.rb', comment_line_pattern, ''

# config/secrets.yml
gsub_file 'config/secrets.yml', comment_line_pattern, ''
gsub_file 'config/secrets.yml', empty_line_pattern, ''

# remove files
run "rm README.rdoc"

git :init
git add: '.'
git commit: "-m 'Initial commit'"
