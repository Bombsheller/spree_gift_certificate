require 'spec_helper'

describe Spree::GiftCertificate do
  let(:certificate) { create(:gift_certificate) }
  let(:recipient) { create(:user) }
  let(:redeemed_certificate) { create(:redeemed_certificate) }
  let(:purchased_certificate) { create(:purchased_certificate) }
  let(:refunded_certificate) { create(:refunded_certificate) }

  context 'redeeming gift certificate' do
    it 'should award store credit when redeemed' do
      purchased_certificate.redeem_for(recipient)
      recipient_total_store_credits = recipient.store_credits_total
      expect(recipient_total_store_credits).to eq(purchased_certificate.amount)
      expect(purchased_certificate.state).to eq("redeemed")
      expect(purchased_certificate.recipient).to eq(recipient)
    end

    context 'with an unredeemable certificate' do
      it 'should not allow redeeming of already redeemed certificate' do
        redemption_status = redeemed_certificate.redeem_for(recipient)
        expect(redemption_status.has_key?(:error)).to eq(true)
      end

      it 'should not allow redeeming of a refunded certificate' do
        redemption_status = redeemed_certificate.redeem_for(recipient)
        expect(redemption_status.has_key?(:error)).to eq(true)
      end
    end

    it 'should not allow redeeming without a recipient' do
      redemption_status = redeemed_certificate.redeem_for(nil)
      expect(redemption_status.has_key?(:error)).to eq(true)
      expect(purchased_certificate.state).to eq(:purchased)
    end
  end

  context 'refunding gift certificate' do
    it 'should allow refunding of a purchased certificate' do
      expect(purchased_certificate.refund).to eq(true)
      expect(purchased_certificate.state).to eq("refunded")
    end

    it 'should not allow refunding of a redeemed certificate' do
      expect(redeemed_certificate.refund).to eq(false)
    end

    it 'should not allow refunding of a refunded certificate' do
      expect(refunded_certificate.refund).to eq(false)
    end
  end

  it 'should allow purchasing if requisite information provided' do
    email = "example@example.com"
    payment_id = 1
    certificate.purchase!({sender_email: email, payment_id: payment_id})
    certificate.reload
    expect(certificate.state).to eq("purchased")
    expect(certificate.sender_email).to eq(email)
    expect(certificate.payment_id).to eq(payment_id)
  end
end