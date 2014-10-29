require 'spec_helper'

describe Spree::GiftCertificate do
  let(:certificate) { create(:gift_certificate) }
  let(:recipient) { certificate.recipient_user }
  let(:redeemed_certificate) { create(:redeemed_certificate) }

  it 'should award store credit when redeemed' do
    certificate.redeem!
    recipient_total_store_credits = recipient.store_credits.to_a.sum { |c| c.remaining_amount }
    expect(recipient_total_store_credits).to eq(certificate.amount)
  end

  it 'should not allow redeeming of already redeemed certificate' do
    expect(redeemed_certificate.redeem).to eq(false)
  end
end