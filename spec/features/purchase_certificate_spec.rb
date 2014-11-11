require 'spec_helper'

describe 'Redeeming a gift certificate', js: true do
  before do
    Spree::GiftCertificate.any_instance.stub(stripe_publishable_key: 'bogus')
    visit '/gift_certificates'
  end

  context 'no logged-in user' do
    it 'should give user helpful errors when not enough information is supplied' do
      click_on 'Buy Gift Certificate'
      wait_for_ajax
      expect(find('#wrapper').find('.flash')).to have_content('Sender email can\'t be blank')
      expect(find('#wrapper').find('.flash')).to have_content('Amount can\'t be blank')
    end
  end
end