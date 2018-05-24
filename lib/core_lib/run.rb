class Run
  attr_reader :headless, :wrap, :browser
  attr_reader :base_logger
  
  def initialize
    @base_logger = Rails.logger.loop
  end
  
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
        
        result = sheet_shiz( @container )
      ensure
        @wrap.browser.close if @wrap.browser.is_open?
      end
    ensure
      $headless.destroy if !$headless.blank?
    end
    @base_logger.info 'END - Run - go'
    result
  end
  
  def client
    url = ENV[ 'sheetsu_api_url_id' ]
    @client ||= Sheetsu::Client.new( url )
  end
  
  def cleanse_tile_text( text )
    cleansed_text = text.sub( '$', '' )
    cleansed_text.sub( ',', '' )
  end
  
  def sheet_shiz( container, sheet_client = nil )
    sheet_client = client if sheet_client.nil?
    
    # well this isn't pretty
    total_revenue = container.total_revenue
    total_orders = container.number_of_orders
    total_fulfillment = container.total_fulfillment_costs
    if !adjustment_last_row.nil?
      total_revenue = adjusted_revenue( cleanse_tile_text( adjustment_last_row[ 'Total Revenue' ] ).to_i, container.total_revenue )
      total_orders = adjusted_number_of_orders( cleanse_tile_text( adjustment_last_row[ 'Total Shopify Orders' ] ).to_i, container.number_of_orders )
      total_fulfillment = adjusted_fulfillment( cleanse_tile_text( adjustment_last_row[ 'Fulfillment' ] ).to_i, container.total_fulfillment_costs )
    end
    
    
    ## Formulas [for now]
    profit = total_revenue - ( total_fulfillment_costs + container.ad_spend + container.transaction_fees )
    roi = profit / container.ad_spend * 100
    conversion_rate = total_orders / container.unique_visitors * 100
    
    sheet_client.create(
      {
        Name: row_name,
        Grouping: grouping,
        Date: date,
        :'Day of Week' => day_of_week,
        Time: row_time,

        :'Total Revenue' => total_revenue,
        :'Total Shopify Orders' => total_orders,
        :'Spend Fomo1' => container.ad_account_1,
        :'Spend Fomo2' => container.ad_account_2,
        :'Spend Fomo4' => container.ad_account_4,
        Spend: container.ad_spend,
        Fulfillment: total_fulfillment,
        Fees: container.transaction_fees,
        :'Refunds in Shopify' => container.refunds,
        :'Unique Visitors' => container.unique_visitors,
        :'The Profit' => profit,
        ROI: roi,
        :'Conversion Rate' => conversion_rate
      }
    )
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
  
  def previous_row_method( sheet_client = nil )
    sheet_client = client if sheet_client.nil?
    
    begin
      rows = sheet_client.read(
        search: { Date: date }
      )
    rescue Sheetsu::NotFoundError
      return nil
    end
    
    rows.last
  end
  
  def second_previous_row_method
    
  end
  
  
  def adjustment_last_row_method( sheet_client = nil, the_adjustment_sheet_name = nil )
    sheet_client = client if sheet_client.nil?
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
