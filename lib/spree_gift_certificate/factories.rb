FactoryGirl.define do
  factory :gift_certificate, class: Spree::GiftCertificate do
    sequence(:code) { |n| "Product ##{n} - #{Kernel.rand(9999)}" }
    amount 25
    gift_to 'Charlie'
    gift_from 'Susan'
    message '<3'

    factory :purchased_certificate do
      state :purchased
      payment_id 5
      sender_email 'example@example.com'

      factory :redeemed_certificate do
        state :redeemed

        after(:create) do |certificate|
          certificate.recipient_user_id = create(:user).id
        end
      end

      factory :refunded_certificate do
        state :refunded
      end
    end
  end
end
