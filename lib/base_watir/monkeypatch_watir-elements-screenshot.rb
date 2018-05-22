# require 'watir-webdriver'
require 'watir'
require 'mini_magick'
require 'oily_png'

module Watir
  class Element
    attr_accessor :tmp_screenshot
    
    def tmp_screenshot
      @tmp_screenshot ||= Tempfile.new( [ 'watirpagesc_', '.png' ] )
    end
    
    def page_screenshot
      tmp_screenshot
      if @tmp_screenshot.size == 0
        browser.screenshot.save( @tmp_screenshot.path )
        # don't think this is needed in this case of how the browser screenshot is being saved
        @tmp_screenshot.rewind
      end
    end
    
    def screenshot_png_tmp( destination)
      file = Tempfile.new( [ 'scsh_', '.png' ] )
      begin
        browser.screenshot.save( file.path )
        image = ChunkyPNG::Image.from_file( file.path )
        image.crop!( wd.location.x.to_i + 1, wd.location.y.to_i + 1, wd.size.width, wd.size.height )
        image.save( destination )
      ensure
        file.unlink
      end
      destination
    end
    
    def screenshot_png( destination )
      page_screenshot
      
      image = ChunkyPNG::Image.from_file( @tmp_screenshot.path )
      image.crop!( wd.location.x.to_i + 1, wd.location.y.to_i + 1, wd.size.width, wd.size.height )
      image.save( destination )
      destination
    end
    
    def test_screenshot_png_confirm_og_image_remains_even_with_exclamation( destination)
      file = Tempfile.new( [ 'scsh_', '.png' ] )
      begin
        browser.screenshot.save( file.path )
        image = ChunkyPNG::Image.from_file( file.path )
        puts 'first'
        puts image.width
        puts image.height
        image.crop!( wd.location.x.to_i + 1, wd.location.y.to_i + 1, wd.size.width, wd.size.height )
        image.save( destination )
        puts 'after !'
        puts image.width
        puts image.height
        imagedeux = ChunkyPNG::Image.from_file( file.path )
        puts 'trying out getting tmp image again'
        puts imagedeux.width
        puts imagedeux.height
      ensure
        file.unlink
      end
      destination
    end
    
    def screenshot_magick_tmp( destination )
      file = Tempfile.new( [ 'scsh_', '.png' ] )
      begin
        browser.screenshot.save( file.path )
        image = MiniMagick::Image.new( file.path )
        image.crop( "#{ wd.size.width }x#{ wd.size.height }+#{ wd.location.x.to_i + 1 }+#{ wd.location.y.to_i + 1 }" )
        image.write( destination )
      ensure
        file.unlink
      end
      destination
    end
    
    def screenshot_magick( destination )
      page_screenshot
      
      image = MiniMagick::Image.open( @tmp_screenshot.path )
      image.crop( "#{ wd.size.width }x#{ wd.size.height }+#{ wd.location.x.to_i + 1 }+#{ wd.location.y.to_i + 1 }" )
      
      image.write( destination )
      destination
    end
    
    def screenshot_magick_centered
    end
    
    def screenshot_scrolling_ajax( destination, y_crop )
      file = Tempfile.new( [ 'ajax_', '.png' ] )
      begin
        browser.screenshot.save( file.path )
        image = MiniMagick::Image.new( file.path )
        image.crop( "#{ wd.size.width }x#{ wd.size.height }+#{ wd.location.x.to_i + 1 }+#{ y_crop + 1 }" )
        image.write( destination )
      ensure
        file.unlink 
      end
    end
  end
end
