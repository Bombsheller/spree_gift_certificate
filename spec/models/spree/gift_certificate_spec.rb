require 'spec_helper'

describe Spree::GiftCertificate do
  let(:certificate) { create(:gift_certificate) }
  let(:recipient) { create(:user) }
  let(:redeemed_certificate) { create(:redeemed_certificate) }
  let(:purchased_certificate) { create(:purchased_certificate) }
  let(:refunded_certificate) { create(:refunded_certificate) }
  let!(:store) { create(:store) }

  context 'redeeming gift certificate' do
    it 'should award store credit when redeemed' do
      purchased_certificate.redeem_for(recipient)
      expect(recipient.store_credits.collect(&:amount).sum).to eq(purchased_certificate.amount)
      expect(purchased_certificate.state).to eq('redeemed')
      expect(purchased_certificate.recipient).to eq(recipient)
    end

    context 'with an unredeemable certificate' do
      it 'should not allow redeeming of already redeemed certificate' do
        redemption_status = redeemed_certificate.redeem_for(recipient)
        expect(redemption_status.key?(:error)).to eq(true)
      end

      it 'should not allow redeeming of a refunded certificate' do
        redemption_status = redeemed_certificate.redeem_for(recipient)
        expect(redemption_status.key?(:error)).to eq(true)
      end
    end

    it 'should not allow redeeming without a recipient' do
      redemption_status = redeemed_certificate.redeem_for(nil)
      expect(redemption_status.key?(:error)).to eq(true)
      expect(purchased_certificate.state).to eq(:purchased)
    end

    it 'should not allow redeeming of expired gift certificate' do
      purchased_certificate.expiry = Date.yesterday
      purchased_certificate.save!
      redemption_status = purchased_certificate.redeem_for(recipient)
      expect(redemption_status.key?(:error)).to eq(true)
    end
  end

  context 'refunding gift certificate' do
    it 'should allow refunding of a purchased certificate' do
      expect(purchased_certificate.refund).to eq(true)
      expect(purchased_certificate.state).to eq('refunded')
    end

    it 'should not allow refunding of a redeemed certificate' do
      expect(redeemed_certificate.refund).to eq(false)
    end

    it 'should not allow refunding of a refunded certificate' do
      expect(refunded_certificate.refund).to eq(false)
    end
  end

  it 'should allow purchasing if requisite information provided' do
    payment_response = OpenStruct.new(params: { 'id' => 'this_is_an_id' })
    ActiveMerchant::Billing::StripeGateway.any_instance.stub(purchase: payment_response)
    Spree::GiftCertificate.any_instance.stub(stripe_secret_key: 'a key! a key!')
    card_id = 'this_is_a_card'
    certificate.purchase!(card_id, store)
    certificate.reload
    expect(certificate.state).to eq('purchased')
    expect(certificate.payment_code).to eq(payment_response.params['id'])
  end
end