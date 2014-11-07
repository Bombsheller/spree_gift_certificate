module Spree
  class GiftCertificatesController < Spree::StoreController

    def new
      @gift_certificate = GiftCertificate.new
      if has_preferred_values
        @preferred_gift_certificate_values = gather_preferred_values
      end
      @current_user_email = spree_current_user.email if spree_current_user
      stripe_payment_methods = Spree::PaymentMethod.available.select { |m| m.type.match /stripe/i }
      @stripe_publishable_key = stripe_payment_methods.first.preferred_publishable_key
    end

    def create
      @gift_certificate = GiftCertificate.create(gift_certificate_params)

      respond_to do |format|
        if @gift_certificate.new_record?
          format.json { render json: @gift_certificate.errors.full_messages, status: :unprocessable_entity }
        else
          format.json { render json: @gift_certificate, status: :created }
        end
      end
    end

    private
      def gift_certificate_params
        params.require(:gift_certificate).permit(:gift_to, :gift_from, :amount, :message, :sender_email)
      end

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