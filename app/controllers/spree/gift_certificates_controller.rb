module Spree
  class GiftCertificatesController < Spree::StoreController

    def new
      @gift_certificate = GiftCertificate.new
      if has_preferred_values
        @preferred_gift_certificate_values = gather_preferred_values
      end
    end

    private
      def has_preferred_values
        has_preferred_values = Spree::Config.has_preference?(:gift_certificate_value_1)
        has_preferred_values ||= Spree::Config.has_preference?(:gift_certificate_value_2)
        has_preferred_values ||= Spree::Config.has_preference?(:gift_certificate_value_3)
      end

      def gather_preferred_values
        preferred_gift_certificate_values = []
        value_1 = Spree::Config.preferred(:gift_certificate_value_1) if Spree::Config.has_preference?(:gift_certificate_value_1)
        value_2 = Spree::Config.preferred(:gift_certificate_value_2) if Spree::Config.has_preference?(:gift_certificate_value_2)
        value_3 = Spree::Config.preferred(:gift_certificate_value_3) if Spree::Config.has_preference?(:gift_certificate_value_3)
        preferred_gift_certificate_values << value_1 if value_1
        preferred_gift_certificate_values << value_2 if value_2
        preferred_gift_certificate_values << value_3 if value_3
      end
  end
end