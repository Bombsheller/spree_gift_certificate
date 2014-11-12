def add_product_to_cart
  create(:product, name: 'RoR Mug')
  visit spree.root_path
  click_link 'RoR Mug'
  click_button 'add-to-cart-button'
end

def fill_in_address
  address = 'order_bill_address_attributes'
  fill_in "#{address}_firstname", with: 'Lucas'
  fill_in "#{address}_lastname", with: 'Eggers'
  fill_in "#{address}_address1", with: '143 Swan Street'
  fill_in "#{address}_city", with: 'Richmond'
  select 'United States of America', from: "#{address}_country_id"
  select 'Alabama', from: "#{address}_state_id"
  fill_in "#{address}_zipcode", with: '12345'
  fill_in "#{address}_phone", with: '(555) 555-5555'
end

# From http://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
def wait_for_ajax
  Timeout.timeout(Capybara.default_wait_time) do
    loop until finished_all_ajax_requests?
  end
end

def finished_all_ajax_requests?
  page.evaluate_script('jQuery.active').zero?
end