require_relative 'helpers/monkeypatch_ruby_basics.rb'
# doesn't fit anywhere
require_relative 'helpers/monkeypatch-overall.rb'

require_relative 'watir_base/watir_base_initializer.rb'

# All the ma_lib files initialized from this file
require_relative 'ma_lib/initializer.rb'

# Actual own code that is running and controlling the code
require_relative 'core_lib/initializer.rb'
