module Spree
  module Admin
    class GiftCertificatesController < ResourceController
      helper_method :resend_object_url
      helper_method :refund_object_url

      def index
        respond_with(@collection)
      end

      def resend
        @gift_certificate.send_purchase_email
        if @gift_certificate.errors.empty?
          flash[:success] = 'Gift certificate email resent.'
        else
          flash[:error] = "Gift certificate not sent! #{@gift_certificate.errors.full_messages.join('<br>')}"
        end
        redirect_to(action: :index)
      end

      def refund
        @gift_certificate.refund
        if @gift_certificate.errors.empty?
          flash[:success] = 'Gift certificate refunded.'
        else
          flash[:error] = "Gift certificate not refunded! #{@gift_certificate.errors.full_messages.join('<br>')}"
        end
        redirect_to(action: :index)
      end

      private

        def collection
          return @collection if @collection.present?
          # params[:q] can be blank upon pagination
          params[:q] = {} if params[:q].blank?

          @collection = super
          @search = @collection.ransack(params[:q])
          @collection = @search.result.
                page(params[:page]).
                per(Spree::Config[:properties_per_page])

          @collection
        end

        def resend_object_url resource
          resend_admin_gift_certificate_url resource
        end

        def refund_object_url resource
          refund_admin_gift_certificate_url resource
        end
    end
  end
end