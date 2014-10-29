FactoryGirl.define do
  factory :gift_certificate, class: Spree::GiftCertificate do
    code 'FieryFuzzyTurtles'
    amount 25
    gift_to 'Charlie'
    gift_from 'Susan'
    message '<3'

    after(:create) do |certificate|
      certificate.recipient_user_id = create(:user).id
    end

    factory :redeemed_certificate do
      state :redeemed
    end

    factory :refunded_certificate do
      state :refunded
    end
  end
end
