# README

This project grabs data from OrderMetrics and places it into Google Sheets. The goal was to get this going as soon as possible so shortcuts were used:
  - I used a lot of my previous codebase, base files, and was in a rush to get a quick working version out. So things like headless chrome aren't used. Though I will try to use it over using Xvfb and headless gem soon.
  - Sheetsu, a paid service is used to read some data and to put the data into a spreadsheet. Eventually there will be an option using an open source, free, Google Sheets gem.
  - Only works with Google Sheets right now as that's what we use

- Tested on Ruby 2.4.2.
- Does not need Rails at all for now. Could grab the initializing files (which I'll list out), lib folder, change some gems from being Rails specific like dotenv-rails, and change any instances of Rails.root and have this project on its own.
- Could easily work on Windows. One or two file paths would have to be adjusted (the only one right now is a path beginning with /opt/). Early version was tested on Windows and it worked.
- Does not use a database for now. So no way for user to change anything yet. Will come soon.

Our ecommerce stack is Shopify. We advertise on Facebook. We were going to grab data from both of those places and potentially Google Analytics to place into a spreadsheet, but we started using OrderMetrics and grabbing from there was easier (though requires Javascript (React) so can't do a simple scraper).

OrderMetrics is a paid service.

If there is interest, I could grab data directly from Facebook, Shopify, Google Analytics, potentially Adwords (though we don't use that yet ourselves) vs paid OrderMetrics being used.
