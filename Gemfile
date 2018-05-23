source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.4.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  
  # Might use these mainstay gems 
  
  # better than irb
  gem 'pry'
  
  # gem 'meta_request' # for the Chrome extension
  gem 'pry-rescue'
  # because I seem to need this if doing rails c stuff that gets rescued
  gem 'pry-rails'
  gem 'jazz_fingers'
  gem 'pry-stack_explorer'
  # gem 'pry-remote'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# scheduling, cron
gem 'whenever', :require => false

# debugging, managing, handling, SaaS, et al.
gem 'sentry-raven'

# DOMAIN
gem 'headless'
# Easy installation and use of chromedriver to run system tests with Chrome
gem 'chromedriver-helper'

# 2018-05, 6.11 coming out soon.
gem 'watir', '~> 6.10'
# gem 'watir-webdriver'
# gem 'selenium-webdriver', '~> 3.11'
gem 'nokogiri'

# needed for watir monkeypatching and own watir files
gem 'mini_magick'
gem 'oily_png'
gem 'user_agent_parser'

# Might use these mainstay gems:

# just other gems
gem 'hashie'

# env variables
gem 'dotenv-rails'

# logging
gem 'multi_logger'

# email
# gem 'sendgrid'
# notifications
# gem 'pushover', github: 'martijnrusschen/pushover'

# automation gluing
# for now since it'll be faster and easier, but pointlessly have to pay for something that isn't needed when there's more time. Plus 1000 row limit per sheet
gem 'sheetsu'
