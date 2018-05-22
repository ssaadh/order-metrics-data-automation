
# If CrawlerLocation isn't created or available (as in the file) the first time it is called upon. Will have a CrawlerLocation class in the near future, but until then, if it is still called, app should continue working, so this will have it be a blank Class.
if defined?( CrawlerLocation ).blank?
  CrawlerLocation = Class.new
end

# Again, same as above. CrawlerDeviceInfo isn't available yet as a class. But if it is still called, app should continue working, so this will have it be a blank Class.
if defined?( CrawlerDeviceInfo ).blank?
  CrawlerDeviceInfo = Class.new
end

# Helps with app working
#Object.const_set( CrawlerDeviceInfo, Class.new ) if defined?( CrawlerDeviceInfo ).nil?

if defined?( TheUserAgent ).blank?
 TheUserAgent = Class.new
end

if defined?( Proxy ).blank?
 Proxy = Class.new
end