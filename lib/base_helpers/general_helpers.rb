module GeneralHelpers
  def self.host_os
    host_os = RbConfig::CONFIG[ 'host_os' ]
    case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /darwin|mac os/
      :macosx
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      :linux
      # "unknown os: #{ host_os.inspect }"
    end
  end
  
  def self.be_headless?
    host_os == :linux# && Rails.env == 'production'
  end
  
  def self.rack_be_headless?
    host_os == :linux# && ENV.key?( 'RACK_ENV' ) && ENV[ 'RACK_ENV' ] == 'production'
  end
  
  def self.unicode_convert( url )
    url.gsub!(/\\u([a-f0-9]{4,5})/i){ [$1.hex].pack('U') }
  end
end