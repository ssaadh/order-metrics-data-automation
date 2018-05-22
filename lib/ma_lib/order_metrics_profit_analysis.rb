module MA
  class OrderMetricsProfitAnalysis < Parent
    ## Variables
    
    def initial_url
      # 'https://app.ordermetrics.io/#'
      'https://app.ordermetrics.io/'   
    end
        
    
    ## Order Metrics Profit Analysis Intro Shiz
    
    def on_and_loaded_profit_analysis?
      profit_analysis_link_element.wait_until_present
      if !profit_analysis_link_element.exist_pres_vis?
        return false
      end
      
      profit_analysis_h2.wait_until_present
      if !profit_analysis_h2.exist_pres_vis?
        return false
      end
      
      revenue_watir.wait_until_present
      if !revenue_watir.exist_pres_vis?
        return false
      end
      
      true
    end
    
      def profit_analysis_h2
        @browser.h2( visible_text: 'Profit Analysis' )
      end
    
      def revenue_watir
        tile_via_watir_element( 'Revenue' )
      end
    
    
    ## Date Range
    
    def date_range_element
      # close enough, not the actual input, but is on the element
      @browser.div( id: 'datepicker' ).div
    end
    
    def date_range_picker_element
      @browser.div( class: 'daterangepicker' )
    end
    
    def date_range_picker_ranges_element
      date_range_picker_element.div( class: 'ranges' )
    end
    
    def date_range_picker_today_element
      date_range_picker_ranges_element.li( visible_text: 'Today' )
    end
    
    def date_range_picker_yesterday_element
      date_range_picker_ranges_element.li( visible_text: 'Yesterday' )
    end
    
    def date_range_actual_dates_element
      # date_range_element.input
      date_range_element.element( class: 'form-control' )      
    end    
    
    # Date Range - actions
    
    def check_for_todays_date?
      # example: 5/20/2018 aka M/D/YYYY
      todays_date_formatted = Date.today.strftime( '%-m/%-d/%Y' )
      full_matching_text = "#{ todays_date_formatted } - #{ todays_date_formatted }"
      date_range_actual_dates_element.attribute_value( :value ) == full_matching_text
    end
    
    def date_range_picker_picker_open
      date_range_element.click
      date_range_picker_ranges_element.wait_until_present
    end
    
    def date_range_picker_pick_today
      date_range_picker_today_element.click
    end
    
    def date_range_picker_pick_yesterday
      date_range_picker_yesterday_element.click
    end
    
    
    ## Loading issue/delay/refresh
    
    def data_updating_element
      @browser.div( id: 'loading-dialog' )
    end
    
    def data_updating_gear_element
      # <img src="/assets/images/gears.gif">
      data_updating_element.img
    end
    
    def data_updating_visible?
      data_updating_element.exist_pres_vis?
    end
    
    def data_still_updating_visible?
      data_updating_text_visible? || data_updating_gear_visible?
    end
    
    def data_updating_gear_visible?
      data_updating_gear_element.exist_pres_vis?
    end
    
    def data_updating_text_visible?
      data_updating_element( visible_text: /Syncing/ )
    end
    
    def data_finished_updating?
      if ( data_updating_element.text == 'Sync is complete. Refresh the page to view updated data.' )
        return true
      end
      
      # if none of the data syncing stuff is visible
      # hard to be firmly logical with this
      data_updating_element.wait_while_present
    end
    
    
    ## Order Metrics Profit Analysis Elements
    
    def cleanse_tile_text( text )
      cleansed_text = text.sub( '$', '' )
      cleansed_text.sub( ',', '' )
    end
    
    def tile_via_watir_element( text )
      # @browser.div( data_title: text ).h2.span
      @browser.div( data_title: text ).h2      
    end
    
    # aggregates both
    def tile_via_watir( text, type = 'integer' )
      watir_element = tile_via_watir_element( text )
      final_text = cleanse_tile_text( watir_element.text )
      if type == 'integer'
        return final_text.to_i
      elsif type == 'float'
        return final_text.to_f
      end
    end
    
    def number_of_orders
      text = 'number of orders'
      tile_via_watir( text )
    end
    
    def revenue
      text = 'Revenue'
      tile_via_watir( text )
    end
    
    def discounts
      text = 'Discounts'
      tile_via_watir( text )
    end
    
    def cogs
      text = 'COGS'
      tile_via_watir( text )
    end
    
    def shipping
      text = 'Shipping Cost'
      tile_via_watir( text )
    end
    
    def transaction_fees
      text = 'Transaction Fees'
      tile_via_watir( text )
    end
    
    def refunds
      text = 'Refunds'
      tile_via_watir( text )
    end
    
    def unique_visitors
      text = '# unique visitors'
      tile_via_watir( text )
    end
    
    def conversion_rate
      
    end
    
    # Useless
    def avg_order_value
      text = 'Avg. Order Value'
      tile_via_watir( text, 'float' )
    end
    
    def avg_order_profit
      text = 'Avg. Order Profit'
      tile_via_watir( text, 'float' )
    end
    
    def ad_spend_per_order
      text = 'ad spend per order'
      tile_via_watir( text, 'float' )
    end
    
    def value_of_a_customer
      text = 'Value of a Customer'
      tile_via_watir( text, 'float' )
    end
    
    def purchase_frequency
      text = 'Purchase Frequency'
      tile_via_watir( text, 'float' )
    end
    
    # This is just the sum number, but the specifics have to be grabbed too
    def ad_spend
      text = 'Ad Spend'
      tile_via_watir( text )
    end
    
    
    ## Adding numbers up
    
    # cogs + shipping + 1% (for things like estimates being off, extra shipping to overseas, being safe)
    def total_fulfillment_costs
      ( cogs + shipping ) * 1.01
    end
    
    # revenue + refunds
    def total_revenue
      revenue + refunds
    end
    
    # total_revenue - ads, fulfillment, fees
    def profit
      total_revenue - ( ad_spend + total_fulfillment_costs + transaction_fees )
    end
    
    
    ## Ad spend
    
    def filter_ad_spend_element
      @browser.button( visible_text: 'Filter Ad Spend' )
    end
    
    def ad_spend_expanded_element      
      # @browser.div( class: 'main-collapse', aria_expanded: 'true' )
      filter_ad_spend_element.parent.div( class: 'main-collapse' )
    end
    
    def is_ad_spend_expanded?
      ad_spend_expanded_element.attribute_value( 'aria-expanded' ) == 'true'
    end
    
    def view_specific_ad_spend_accounts
      filter_ad_spend_element.focus
      filter_ad_spend_element.click
      
      if !is_ad_spend_expanded?
        # try again
        sleep 1
        filter_ad_spend_element.focus
        filter_ad_spend_element.click
      end
      
      @browser.span( class: 'spend-indicator' ).wait_until_present
    end
    
    def ad_spend_clean( text )
      watir_element = specific_ad_spend_account_amount_element( text )
      final_text = cleanse_tile_text( watir_element.text )
      final_text.to_f
    end
    
    def specific_ad_spend_account_amount( name )
      ad_spend_clean( name )    
    end
    
    def specific_ad_spend_account_amount_element( name )
      filter_ad_spend_element.parent.span( visible_text: name ).parent.parent.span( class: 'spend-indicator' )
    end
  end
end
