# .gitignore
run 'gibo Rails > .gitignore' rescue nil

# Gemfile
create_file 'Gemfile', '', force: true
add_source 'https://rubygems.org'
add_source 'https://rails-assets.org'

gem_group :default do
  gem 'rails', '4.2.1'
  gem 'sqlite3'
  gem 'sass-rails', '~> 5.0'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.1.0'
  gem 'jbuilder', '~> 2.0'
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
  gem 'web-console', '~> 2.0'
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

gem_group :doc do
  gem 'sdoc', '~> 0.4.0'
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
create_file 'config/routes.rb', <<RB, force: true
Rails.application.routes.draw do
  root 'pages#index'
end
RB

# Rakefile
gsub_file 'Rakefile', /^\s*#.*\n/, ''

# remove files
run "rm README.rdoc"

git :init
git add: '.'
git commit: "-m 'Initial commit'"
