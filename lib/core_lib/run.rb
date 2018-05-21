class Run
  attr_reader :headless, :wrap, :browser
  attr_reader :base_logger
  
  def initialize
    @base_logger = Rails.logger.loop
  end
  
  def official_initial( display_number = nil )
    @base_logger.info 'BEGIN - Run - initial'
    
    $headless = nil
    if GeneralHelpers.host_os == :linux
      unless display_number.nil?
        $headless = Headless.new( display: display_number )
        $headless.start
      end
    end
    
    @wrap = TheBasics.new( :chrome, $headless )
    
    @base_logger.info 'END - Run - initial'
    
    return $headless, @wrap
  end
  
  def go( display_number = nil )
    display_number = rand( 11..99 ) if display_number.nil?
    $headless, @wrap = official_initial( display_number )
    begin
      begin
        @login = Login.new( @wrap )
        @pa = OrderMetricsProfitAnalysis.new( @wrap )
        
        Pry::rescue{
        login_result = @login.login
        
        @container = @pa.run
                
        # @TODO have the API url somewhere that can be changed without version controlled code
        @client = Sheetsu::Client.new( 'e317450b7654' )
        
        total_revenue = adjusted_revenue( last_row.total_revenue, @container.total_revenue )
        total_orders = adjusted_orders( last_row.total_shopify_orders, @container.number_of_orders )
        total_fulfillment = adjusted_fulfillment( last_row.fulfillment, @container.total_fulfillment_costs )
        
        @client.create(
          {
            Name: name,
            Grouping: grouping,
            Date: date,
            :'Day of Week' => day_of_week,
            Time: time,
            
            :'Total Revenue' => total_revenue,
            :'Total Shopify Orders' => total_orders,
            :'Spend Fomo1' => @container.ad_account_1,
            :'Spend Fomo2' => @container.ad_account_2,
            :'Spend Fomo4' => @container.ad_account_4,
            Spend: @container.ad_spend,
            Fulfillment: total_fulfillment,
            Fees: @container.transaction_fees,
            :'Refunds in Shopify' => @container.refunds,
          }
        )
        }
      ensure
        @wrap.browser.close if @wrap.browser.is_open?
      end
    ensure
      $headless.destroy if !$headless.blank?
    end
  end
  
  
  ## Not scraped sheet values
  
  def date
    # basic 2018-05-21 style
    Date.today.strftime( '%Y-%m-%d' )
  end
  
  def time
    # Just the hour, zero-padded
    DateTime.today.strftime( '%H' )
  end
  
  def row_name
    # date plus hour
    "#{ date } #{ time }"
  end
  
  def day_of_week
    Date.today.strftime( '%A' )
  end
  
  # @TODO set to a variable that can be adjusted
  def grouping    
    'D1'
  end
  
  
  ## Adjustments
  
  # @TODO set to a variable that can be adjusted
  def adjustment_sheet_name
    '2018-05 daily adjustments'
  end
  
  def last_row_method( client = nil, the_adjustment_sheet_name = nil )
    client = @client if client.nil?
    the_adjustment_sheet_name = adjustment_sheet_name if the_adjustment_sheet_name.nil?
    
    rows = client.read( 
    search: { Date: date },
    sheet: adjustment_sheet_name
    )
    
    rows.last
  end
  
  def last_row( client = nil )
    @last_row ||= last_row_method( client )
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
