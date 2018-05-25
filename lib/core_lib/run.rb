class Run
  attr_reader :headless, :wrap, :browser
  attr_reader :base_logger
  
  
  ## Initial
  
  def initialize
    @base_logger = Rails.logger.loop
    
    pushover
  end
  
  def sheetsu
    url = ENV[ 'sheetsu_api_url_id' ]
    @sheetsu ||= Sheetsu::Client.new( url )
  end
  
  def pushover
    Pushover.configure do | config |
      config.user = ENV[ 'pushover_user' ]
      config.token = ENV[ 'pushover_token' ]
    end
  end
  
  
  ## Core
  
  def go( display_number = nil )
    @base_logger.info 'BEGIN - Run - go'
    setup = Setup.new
    $headless, @wrap = setup.default( display_number )
    begin
      begin
        @login = Login.new( @wrap )
        @pa = OrderMetricsProfitAnalysis.new( @wrap )
        
        login_result = @login.login
        
        @container = @pa.run
        total_adjusted = total_adjusted_amounts( @container )
    
        @formulas = formulas_replacement( total_adjusted, @container )
        
        result_sheet = sheet_shiz( total_adjusted, @container, @formulas )
        
        result_push = pushover_notification( total_adjusted, @container, @formulas )                
      ensure
        @wrap.browser.close if @wrap.browser.is_open?
      end
    ensure
      $headless.destroy if !$headless.blank?
    end
    @base_logger.info 'END - Run - go'
    result_sheet, result_push
  end
    
    # copy pasted, needed here
    def cleanse_tile_text( text )
      cleansed_text = text.sub( '$', '' )
      cleansed_text.sub( ',', '' )
    end
  
  
  ## Core integrations
  
  def sheet_shiz( total_adjusted, container, formulas, sheet_client = nil )
    sheet_client = sheetsu if sheet_client.nil?
    
    sheet_client.create(
      {
        Name: row_name,
        Grouping: grouping,
        Date: date,
        :'Day of Week' => day_of_week,
        Time: row_time,

        :'Total Revenue' => total_adjusted.revenue,
        :'Total Shopify Orders' => total_adjusted.orders,
        :'Spend Fomo1' => container.ad_account_1,
        :'Spend Fomo2' => container.ad_account_2,
        :'Spend Fomo4' => container.ad_account_4,
        Spend: container.ad_spend,
        Fulfillment: total_adjusted.fulfillment,
        Fees: container.transaction_fees,
        :'Refunds in Shopify' => container.refunds,
        :'Unique Visitors' => container.unique_visitors,
        :'The Profit' => @formulas.profit,
        ROI: @formulas.roi,
        :'Conversion Rate' => @formulas.conversion_rate,
        
        :'Last Check Spend' => @formulas.last_check.spend,
        :'Last Check Profit' => @formulas.last_check.profit,
        :'Last Check ROI' => @formulas.last_check.roi,
        :'Last Check Conversion' => @formulas.last_check.conversion_rate,
        
        :'2nd Last Check Spend' => @formulas.second_last_check.spend,
        :'2nd Last Check Profit' => @formulas.second_last_check.profit,
        :'2nd Last Check ROI' => @formulas.second_last_check.roi,
        :'2nd Last Check Conversion' => @formulas.second_last_check.conversion_rate,
      }
    )
  end
  
  def pushover_notification( total_adjusted, container, formulas, pushover_client = nil )    
    # title =
    # message =
    # Pushover.notification( title: title, message: message )
  end
  
  
  ## Segment out shiz
  
  def total_adjusted_amounts( container = nil, adjusted_last_row = nil )
    container = @container if container.nil?
    adjusted_last_row = adjustment_last_row if adjusted_last_row.nil?
    
    # well this isn't pretty
    adjusted_totals = Hashie::Mash.new
    adjusted_totals.revenue = container.total_revenue
    adjusted_totals.orders = container.number_of_orders
    adjusted_totals.fulfillment = container.total_fulfillment_costs
    
    if !adjustment_last_row.nil?
      adjusted_totals.revenue = adjusted_revenue( cleanse_tile_text( adjusted_last_row[ 'Total Revenue' ] ).to_i, container.total_revenue )
      adjusted_totals.orders = adjusted_number_of_orders( cleanse_tile_text( adjusted_last_row[ 'Total Shopify Orders' ] ).to_i, container.number_of_orders )
      adjusted_totals.fulfillment = adjusted_fulfillment( cleanse_tile_text( adjusted_last_row[ 'Fulfillment' ] ).to_i, container.total_fulfillment_costs )
    end
    
    adjusted_totals
  end
  
  def formulas_container
    @formulas = Hashie::Mash.new
    
    @formulas.profit = nil
    @formulas.roi = nil
    @formulas.conversion_rate = nil
    
    @formulas.last_check = Hashie::Mash.new
    @formulas.last_check.spend = nil
    @formulas.last_check.profit = nil
    @formulas.last_check.roi = nil
    @formulas.last_check.conversion_rate = nil
    
    @formulas.second_last_check = Hashie::Mash.new
    @formulas.second_last_check.spend = nil
    @formulas.second_last_check.profit = nil
    @formulas.second_last_check.roi = nil
    @formulas.second_last_check.conversion_rate = nil
    
    @formulas
  end
  
  # formulas [for now]
  def formulas_replacement( total_adjusted, container = nil )
    container = @container if container.nil?
    
    @formulas = formulas_container
    
    @formulas.profit = total_adjusted.revenue - ( total_adjusted.fulfillment + container.ad_spend + container.transaction_fees )
    @formulas.roi = @formulas.profit / container.ad_spend * 100
    @formulas.conversion_rate = total_adjusted.orders.to_f / container.unique_visitors * 100
    
    if !previous_row.nil?
      @formulas.last_check.spend = container.ad_spend - previous_row[ :spend ]
      @formulas.last_check.profit = @formulas.profit - previous_row[ :profit ]
      @formulas.last_check.roi = @formulas.last_check.profit / @formulas.last_check.spend * 100
      @formulas.last_check.conversion_rate = ( total_adjusted.orders - previous_row[ :orders ] ) / ( container.unique_visitors - previous_row[ :unique_visitors ] ) * 100
    end
    
    if !second_previous_row.nil?
      @formulas.second_last_check.spend = container.ad_spend - second_previous_row[ :spend ]
      @formulas.second_last_check.profit = @formulas.profit - second_previous_row[ :profit ]
      @formulas.second_last_check.roi = @formulas.second_last_check.profit / @formulas.second_last_check.spend * 100
      @formulas.second_last_check.conversion_rate = ( total_adjusted.orders.to_f - second_previous_row[ :orders ] ) / ( container.unique_visitors.to_f - second_previous_row[ :unique_visitors ] ) * 100
    end
    
    @formulas
  end
  
  
  def previous_row_method( sheet_client = nil )
    rows = previous_rows_intro( sheet_client )
    # rows.last if result.kind_of? Array
    previous_rows_coercion( rows.last ) unless rows.blank?    
  end
  
  def previous_row( sheet_client = nil )
    @previous_row ||= previous_row_method( sheet_client )
  end
  
  def second_previous_row_method( sheet_client = nil )
    rows = previous_rows_intro( sheet_client )
    
    # if result.kind_of? Array        
    if !rows.blank? && rows.length > 1
      return previous_rows_coercion( rows[ -2 ] )
    end
  end
  
  def second_previous_row( sheet_client = nil )
    @second_previous_row ||= second_previous_row_method( sheet_client )
  end
  
    def previous_rows_intro( sheet_client = nil )
      sheet_client = sheetsu if sheet_client.nil?
    
      begin
        rows = sheet_client.read(
          search: { Date: date }
        )
      rescue Sheetsu::NotFoundError
        return nil
      end
      rows
    end
  
    def previous_rows_coercion( row )
      return nil if row.blank?
    
      row[ :spend ] = row[ 'Spend' ].to_i
      row[ :profit ] = row[ 'The Profit' ].to_i
      row[ :orders ] = row[ 'Total Shopify Orders' ].to_f
      row[ :unique_visitors ] = row[ 'Unique Visitors' ].to_f
    
      row    
    end
  
  
  ## Not scraped sheet values
  
  def date
    # basic 2018-05-21 style
    Date.today.strftime( '%Y-%m-%d' )
  end
  
  def time
    # Just the hour, zero-padded
    # nvm, now the minutes too. would like it to be 00 or 30, but will see if it goes past a minute
    DateTime.now.strftime( '%H:%M' )
  end
  
  def row_time
    "#{ time }"
  end
  
  def row_name
    # date plus hour
    "#{ date } #{ time }"
  end
  
  def day_of_week
    Date.today.strftime( '%A' )
  end
  
  def grouping
    ENV[ 'grouping' ]
  end
  
  
  ## Adjustments
  
  def adjustment_sheet_name
    ENV[ 'adjustment_sheet' ]
  end
  
  def adjustment_last_row_method( sheet_client = nil, the_adjustment_sheet_name = nil )
    sheet_client = sheetsu if sheet_client.nil?
    the_adjustment_sheet_name = adjustment_sheet_name if the_adjustment_sheet_name.nil?
    
    begin
      rows = sheet_client.read(
        search: { Date: date },
        sheet: "#{ adjustment_sheet_name }",
      )
    rescue Sheetsu::NotFoundError
      return nil
    end
    
    rows.last
  end
  
  def adjustment_last_row( sheet_client = nil )
    @last_row ||= adjustment_last_row_method( sheet_client )
  end
  
  def adjusted_value( adjusted_value, og_total_value )
    if adjusted_value.to_i != 0
      og_total_value -= adjusted_value
    end
    og_total_value
  end
  
  def adjusted_revenue( adjusted_revenue, total_revenue )
    adjusted_value( adjusted_revenue, total_revenue )
  end
  
  def adjusted_number_of_orders( adjusted_orders, total_orders )
    adjusted_value( adjusted_orders, total_orders )
  end
  
  def adjusted_fulfillment( adjusted_fulfillment, total_fulfillment )
    adjusted_value( adjusted_fulfillment, total_fulfillment )
  end  
end
