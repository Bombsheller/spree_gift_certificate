module Spree
  module Admin
    class GiftCertificatesController < ResourceController
      def index
        respond_with(@collection)
      end

      private

        def collection
          p @collection
          return @collection if @collection.present?
          # params[:q] can be blank upon pagination
          params[:q] = {} if params[:q].blank?

          @collection = super
          p @collection
          @search = @collection.ransack(params[:q])
          @collection = @search.result.
                page(params[:page]).
                per(Spree::Config[:properties_per_page])

          @collection
        end
    end
  end
end