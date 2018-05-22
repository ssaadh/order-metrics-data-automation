class OrderMetricsProfitAnalysis < Parent
  def initialize( wrap )
    super( wrap )
    @lib = MA::OrderMetricsProfitAnalysis.new( wrap )
  end
  
  def single
    @container = Hashie:Mash.new
    
    @container.number_of_orders = nil
    @container.revenue = nil
    @container.discounts = nil
    @container.cogs = nil
    @container.shipping = nil
    @container.transaction_fees = nil
    @container.refunds = nil
    @container.avg_order_value = nil
    @container.avg_order_profit = nil
    @container.ad_spend_per_order = nil
    @container.value_of_a_customer = nil
    @container.purchase_frequency = nil
    
    @container.total_fulfillment_costs = nil
    @container.total_revenue = nil
    @container.profit = nil        
    
    @container.ad_spend = nil
    
    @container.ad_account_1 = nil
    @container.ad_account_2 = nil
    @container.ad_account_4 = nil
    
    @container
  end
  
  def run
    result = load
    
    @container = single
    
    @container = grab_data( @container )
    @container = specific_ad_accounts( @container )
    
    # k, could've just ended with line above without assigning
    @container
  end
  
  def load
    @lib.on_and_loaded_profit_analysis?
    
    sleep 1
    
    if !@lib.check_for_todays_date?
      @lib.date_range_picker_element.click
      date_range_picker_today_element.wait_until_present
      date_range_picker_today_element.click
    end
    
    @lib.data_updating_gear_element.wait_while_present
    # dno
    sleep 5
    
    @browser.refresh
    
    result = @lib.on_and_loaded_profit_analysis?
    # dno
    sleep 5 if result
    
    result
  end
  
  def grab_data( container )
    container.number_of_orders = @lib.number_of_orders
    container.revenue = @lib.revenue
    # container.discounts = @lib.discounts
    container.cogs = @lib.cogs
    container.shipping = @lib.shipping
    container.transaction_fees = @lib.transaction_fees
    container.refunds = @lib.refunds
    
    container.total_fulfillment_costs = @lib.total_fulfillment_costs
    container.total_revenue = @lib.total_revenue
    # container.profit = nil = @lib.profit
    
    container.unique_visitors = @lib.unique_visitors
    
    container.ad_spend = @lib.ad_spend
    
    container
  end
  
  def specific_ad_accounts( container )
    result = @lib.view_specific_ad_spend_accounts
    
    container.ad_account_1 = @lib.specific_ad_spend_account_amount( 'FomoSupplyCo' )
    container.ad_account_2 = @lib.specific_ad_spend_account_amount( 'FomoSupplyCo 2' )
    container.ad_account_4 = @lib.specific_ad_spend_account_amount( 'FomoSupplyCo 4' )
    
    container
  end
end
