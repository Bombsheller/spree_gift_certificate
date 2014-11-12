require 'spec_helper'

# Please note what is NOT TESTED HERE: the actual Stripe modal popup and payment
# errors. The reason being I don't want to put my personal test API keys into the
# application. I've written tests for and clicked through the process using a
# Spree test app and have ensured it works, for me at least ;-). When integrating,
# make sure you test with your test API keys and walk through the code paths
# involving payment errors in your application's repo.
describe 'Purchasing a gift certificate', js: true do
  let(:user) { create(:user) }

  before do
    Spree::GiftCertificate.any_instance.stub(stripe_publishable_key: 'bogus',
                                             stripe_secret_key: 'a key! a key!')

    payment_response = OpenStruct.new(params: { 'id' => 'this_is_an_id' })
    ActiveMerchant::Billing::StripeGateway.any_instance.stub(purchase: payment_response)
  end

  context 'as a guest' do
    before do
      visit '/gift_certificates'
    end
    it 'should give user helpful errors when not enough information is supplied' do
      click_on 'Buy Gift Certificate'
      wait_for_ajax
      expect(find('#wrapper').find('.flash')).to have_content('Sender email can\'t be blank')
      expect(find('#wrapper').find('.flash')).to have_content('Amount can\'t be blank')
    end

    it 'should allow purchase' do
      sender_email = 'spree@example.com'
      fill_in 'gift_certificate_sender_email', with: sender_email
      amount = 5
      fill_in 'gift_certificate_amount', with: amount
      click_on 'Buy Gift Certificate'
      wait_for_ajax
      expect(find('#wrapper')).to_not have_content('Sender email can\'t be blank')
      expect(find('#wrapper')).to_not have_content('Amount can\'t be blank')

      certificate = Spree::GiftCertificate.find_by_sender_email(sender_email)
      certificate_id = certificate.id
      expect(certificate.state).to eq('pending')
      expect(certificate.sender_email).to eq(sender_email)
      expect(certificate.code.nil?).to eq(false)
      expect(certificate.amount).to eq(amount)

      page.evaluate_script("jQuery.post('/buy_gift_certificate', {id: #{certificate_id},
                                                                  stripeToken: {id: 'also_bogus'}},
                                                                  function () { console.log('success'); })")
      wait_for_ajax

      certificate.reload
      expect(certificate.state).to eq('purchased')
      expect(certificate.expiry).to eq(1.year.from_now.to_date)
    end
  end

  context 'as a logged-in user' do
    before do
      Spree::BaseController.any_instance.stub(:spree_current_user).and_return(user)
      visit '/gift_certificates'
    end

    it 'should auto-fill email address in the form' do
      expect(find('#gift_certificate_sender_email').value).to eq(user.email)
    end

    it 'should allow filling of all form elements' do
      amount = 5
      gift_from = 'mom'
      gift_to = 'son'
      message = 'hope you like your leggings!'
      fill_in 'gift_certificate_amount', with: amount
      fill_in 'gift_certificate_gift_from', with: gift_from
      fill_in 'gift_certificate_gift_to', with: gift_to
      fill_in 'gift_certificate_message', with: message
      click_on 'Buy Gift Certificate'
      wait_for_ajax

      certificate = Spree::GiftCertificate.find_by_sender_email(user.email)
      expect(certificate.amount).to eq(amount)
      expect(certificate.sender_email).to eq(user.email)
      expect(certificate.gift_from).to eq(gift_from)
      expect(certificate.gift_to).to eq(gift_to)
      expect(certificate.message).to eq(message)
    end
  end

  context 'with preferred values' do
    before do
      Spree::AppConfiguration.class_eval do
        preference :gift_certificate_value_2, :number, default: 30
        preference :gift_certificate_value_3, :number, default: 40
      end
      visit '/gift_certificates'
    end

    it 'should show <select>' do
      expect(page).to have_selector('select#gift_certificate_amount')
    end

    it 'should reveal input upon clicking custom value button' do
      click_on 'Custom value'
      expect(page).to have_selector('input#gift_certificate_amount', visible: true)
    end

    it 'should auto-fill form' do
      default_value = Spree::Config.preferred(:gift_certificate_value_2).to_s
      expect(find('input#gift_certificate_amount', visible: false).value).to eq(default_value)

      other_value = Spree::Config.preferred(:gift_certificate_value_3).to_s
      select(other_value, from: 'gift_certificate_amount')
      expect(find('input#gift_certificate_amount', visible: false).value).to eq(other_value)
    end
  end
end