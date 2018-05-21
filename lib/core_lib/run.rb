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
        
        login_result = @login.login
        
        @container = @pa.run
        
        # @TODO have the API url somewhere that can be changed without version controlled code
        @client = Sheetsu::Client.new( 'e317450b7654' )
        
        
        ## Not scraped sheet values
        
        # basic 2018-05-21 style
        date = Date.today.strftime( '%Y-%m-%d' )        
        # Just the hour, zero-padded
        time = DateTime.today.strftime( '%H' )
        
        # date plus hour
        name = "#{ date } #{ time }"
        # set to a variable that can be adjusted
        grouping = 'D1'        
        day_of_week = Date.today.strftime( '%A' )
        
        
        ## Adjustments from scraped values
        # @TODO sheet name should be in some variable outside of version control
        rows = @client.read( 
        search: { Date: date },
        sheet: '2018-05 daily adjustments'
        )
        
        last_row = rows.last
        
        total_revenue = @container.total_revenue
        if last_row.total_revenue.to_i != 0
          total_revenue = total_revenue - last_row.total_revenue
        end
        
        total_orders = @container.number_of_orders
        if last_row.total_shopify_orders.to_i != 0
          total_orders = total_orders - last_row.total_shopify_orders
        end
        
        total_fulfillment = @container.total_fulfillment_costs
        if last_row.fulfillment.to_i != 0
          total_fulfillment = total_fulfillment - last_row.fulfillment
        end
        
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
      ensure
        @wrap.browser.close if @wrap.browser.is_open?
      end
    ensure
      $headless.destroy if !$headless.blank?
    end
  end
end
