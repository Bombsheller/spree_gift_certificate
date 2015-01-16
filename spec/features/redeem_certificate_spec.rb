require 'spec_helper'

describe 'Redeeming a gift certificate', js: true do
  let(:purchased_certificate)  { create(:purchased_certificate) }
  let(:user) { create(:user) }

  let!(:country) { create(:country, states_required: true) }
  let!(:state) { create(:state, country: country) }
  let!(:shipping_method) { create(:shipping_method) }
  let!(:stock_location) { create(:stock_location) }
  let!(:payment_method) { create(:credit_card_payment_method) }
  let!(:zone) { create(:zone) }

  context 'user not signed in' do
    before do
      add_product_to_cart
    end

    it 'should not allow redemption if no user is signed in' do
      visit spree.cart_path
      fill_in 'order_coupon_code', with: purchased_certificate.code
      click_on 'update-button'
      expect(page).to have_content('Need to be logged in to redeem a gift certificate.')
    end

    it 'should tell user to sign in even if expired' do
      visit spree.cart_path
      purchased_certificate.expiry = Date.yesterday
      purchased_certificate.save!
      fill_in 'order_coupon_code', with: purchased_certificate.code
      click_on 'update-button'
      expect(page).to have_content('Need to be logged in to redeem a gift certificate.')
    end
  end

  context 'user signed in' do
    before do
      Spree::BaseController.any_instance.stub(:spree_current_user).and_return(user)
      add_product_to_cart
      visit spree.cart_path
    end

    it 'should allow redeption on cart screen' do
      fill_in 'order_coupon_code', with: purchased_certificate.code
      click_on 'update-button'
      expect(page).to have_content('Successfully redeemed gift certificate')
      expect(user.store_credits_total).to eq(purchased_certificate.amount)
    end

    it 'should not allow redemption of expired certificate' do
      purchased_certificate.expiry = Date.yesterday
      purchased_certificate.save!
      fill_in 'order_coupon_code', with: purchased_certificate.code
      click_on 'update-button'
      expect(page).to have_content('Gift card has expired.')
      expect(user.store_credits.collect(&:amount).sum).to eq(0)
    end

    it 'should allow redemption on payment screen and then use store credits to pay' do
      click_on 'Checkout'
      fill_in_address
      click_button 'Save and Continue'
      click_button 'Save and Continue'
      fill_in 'order_coupon_code', with: purchased_certificate.code
      click_on 'Save and Continue'
      expect(page).to have_content('Successfully redeemed gift certificate')
      expect(user.store_credits_total).to eq(purchased_certificate.amount)
    end

  end
end