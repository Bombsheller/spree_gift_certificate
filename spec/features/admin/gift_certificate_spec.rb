require 'spec_helper'

describe 'Admin gift certificate management', js: true do
  let!(:user) { create(:admin_user) }
  let!(:gift_certificate) { create(:gift_certificate) }
  let!(:purchased_certificate) { create(:purchased_certificate) }
  let!(:redeemed_certificate) { create(:redeemed_certificate) }
  let!(:refunded_certificate) { create(:refunded_certificate) }
  let!(:store) { create(:store) }

  before do
    Spree::Admin::BaseController.any_instance.stub(:spree_current_user).and_return(user)
    visit '/admin/gift_certificates'
    allow_any_instance_of(ApplicationController).to receive(:current_store).and_return(store)
  end

  context 'browsing admin panel' do
    def gift_certificate_present_in_table(table, certificate)
      expect(table).to have_content(certificate.code)
      expect(table).to have_content(certificate.state)
      expect(table).to have_content(certificate.amount)
      expect(table).to have_content(certificate.sender_email)
      expect(table).to have_content(certificate.gift_from) if certificate.gift_from
      expect(table).to have_content(certificate.gift_to) if certificate.gift_to
      expect(table).to have_content(certificate.expiry) if certificate.expiry
      expect(table).to have_content(certificate.message) if certificate.message
    end

    it 'should have gift certificate navigation link' do
      expect(find('#sub_nav')).to have_content('Gift Certificates'.upcase)
    end

    it 'should list all gift certificates' do
      gift_certificates_table = find('#listing_gift_certificates')
      gift_certificate_present_in_table(gift_certificates_table, gift_certificate)
      gift_certificate_present_in_table(gift_certificates_table, purchased_certificate)
      gift_certificate_present_in_table(gift_certificates_table, redeemed_certificate)
      gift_certificate_present_in_table(gift_certificates_table, refunded_certificate)
    end

    it 'should play nice with code search box' do
      gift_certificates_table = find('#listing_gift_certificates')
      fill_in 'q_code_cont', with: purchased_certificate.code
      click_button 'Search'
      gift_certificate_present_in_table(gift_certificates_table, purchased_certificate)
      expect(gift_certificates_table).to_not have_content(redeemed_certificate.code)
      expect(gift_certificates_table).to_not have_content(gift_certificate.code)
      expect(gift_certificates_table).to_not have_content(refunded_certificate.code)
    end

    it 'should play nice with email search box' do
      gift_certificates_table = find('#listing_gift_certificates')
      new_email = 'unique@unique.com'
      gift_certificate.sender_email = new_email
      gift_certificate.save!
      fill_in 'q_sender_email_cont', with: gift_certificate.sender_email
      click_button 'Search'
      gift_certificate_present_in_table(gift_certificates_table, gift_certificate)
      expect(gift_certificates_table).to_not have_content(redeemed_certificate.code)
      expect(gift_certificates_table).to_not have_content(purchased_certificate.code)
      expect(gift_certificates_table).to_not have_content(refunded_certificate.code)
    end
  end

  context 'admin panel gift certificate actions' do
    it 'should allow resending of gift certificate email' do
      # So emails will be stored in the deliveries array
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.deliveries = []
      visit "/admin/gift_certificates/#{purchased_certificate.id}/resend"
      expect(ActionMailer::Base.deliveries.length).to eq(1)
    end

    it 'should allow refunding of purchased certificate' do
      visit "/admin/gift_certificates/#{purchased_certificate.id}/refund"
      purchased_certificate.reload
      expect(purchased_certificate.state).to eq('refunded')
    end

    it 'should not allow refunding of redeemed certificate' do
      visit "/admin/gift_certificates/#{redeemed_certificate.id}/refund"
      expect(page).to have_content('Gift certificate not refunded!')
      redeemed_certificate.reload
      expect(redeemed_certificate.state).to eq('redeemed')
    end
  end

  context 'editing a gift certificate' do
    before do
      visit "/admin/gift_certificates/#{purchased_certificate.id}/edit"
    end

    it 'should not allow editing of state, expiry, amount or payment fields' do
      expect(page).to_not have_selector('#gift_certificate_amount_field input')
      expect(page).to_not have_selector('#gift_certificate_expiry_field input')
      expect(page).to_not have_selector('#gift_certificate_state_field input')
      expect(page).to_not have_selector('#gift_certificate_payment_code_field input')
    end

    it 'should allow editing of message, gift from and to, code, and sender email' do
      sender_email = 'changed@changed.edu'
      code = 'well this is different'
      gift_from = 'grandma'
      gift_to = 'grandson'
      message = 'something you\'ve never seen before!'
      fill_in 'gift_certificate_code', with: code
      fill_in 'gift_certificate_sender_email', with: sender_email
      fill_in 'gift_certificate_gift_from', with: gift_from
      fill_in 'gift_certificate_gift_to', with: gift_to
      fill_in 'gift_certificate_message', with: message

      click_button 'Update'
      wait_for_ajax

      purchased_certificate.reload

      expect(purchased_certificate.code).to eq(code)
      expect(purchased_certificate.gift_from).to eq(gift_from)
      expect(purchased_certificate.gift_to).to eq(gift_to)
      expect(purchased_certificate.message).to eq(message)
      expect(purchased_certificate.sender_email).to eq(sender_email)
    end

    it 'should not allow changing of code to a code already in use' do
      original_code = purchased_certificate.code

      fill_in 'gift_certificate_code', with: gift_certificate.code
      click_button 'Update'
      expect(page).to have_content('Code has already been taken')

      purchased_certificate.reload
      expect(purchased_certificate.code).to eq(original_code)
    end
  end
end