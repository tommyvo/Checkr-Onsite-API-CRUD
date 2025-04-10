module Api
  module V1
    class AddressesController < ApplicationController
      before_action :load_address, only: %i[update destroy]

      # GET /api/v1/addresses
      def index
        @addresses = Address.all
        render json: @addresses
      end

      # POST /api/v1/addresses
      def create
        csv_importer = AddressCsvImporter.new(params[:file])

        if csv_importer.import
          render json: { message: "CSV processed" }, status: 200
        else
          render json: { error: "Unable to process CSV file!" }, status: 500
        end
      end

      # TODO: make this accept a JSON payload, instead of just the parameters
      # PUT /api/v1/addresses/:id
      def update
        if @address.update(address_params)
          render json: { message: "Address updated successfully" }, status: 200
        else
          render json: { error: "Unable to update address: #{@address.errors.full_messages}" }, status: 400
        end
      end

      # DELETE /api/v1/addresses/:id
      def destroy
        if @address.destroy
          render json: { message: "Address destroyed successfully" }, status: 200
        else
          render json: { error: "Unable to destroy address: #{@address.errors.full_messages}" }, status: 400
        end
      end

      private

      def address_params
        params.require(:address).permit(:street_address, :secondary_address, :city, :state, :zip)
      end

      def load_address
        @address = Address.find_by(id: params[:id])

        if @address.nil?
          render json: { error: "Address not found" }, status: 404
        end
      end
    end
  end
end
