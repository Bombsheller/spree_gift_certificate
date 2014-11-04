require 'spec_helper'

describe 'Redeeming a gift certificate' do
  let(:purchased_certificate)  { create(:purchased_certificate) }

  before do
    add_product_to_cart
  end

  context 'user not signed in' do
    it 'should not allow redemption if no user is signed in', :js => true do
      visit spree.cart_path
      fill_in 'order_coupon_code', with: purchased_certificate.code
      click_on 'update-button'
      expect(page).to have_content('Need to be logged in to redeem a gift certificate.')
    end
  end
end