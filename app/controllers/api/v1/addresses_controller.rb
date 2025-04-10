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
        csv_importer = AddressCsvImporter.new(import_file_param)

        if csv_importer.import
          render json: { message: "CSV processed" }, status: :ok
        else
          render json: { error: "Unable to process CSV file!" }, status: :unprocessable_entity
        end
      end

      # TODO: make this accept a JSON payload, instead of just the parameters
      # PUT /api/v1/addresses/:id
      def update
        if @address.update(address_params)
          render json: { message: "Address updated successfully" }, status: :ok
        else
          render json: { error: "Unable to update address: #{@address.errors.full_messages}" }, status: :bad_request
        end
      end

      # DELETE /api/v1/addresses/:id
      def destroy
        if @address.destroy
          render json: { message: "Address destroyed successfully" }, status: :ok
        else
          render json: { error: "Unable to destroy address: #{@address.errors.full_messages}" }, status: :bad_request
        end
      end

      private

      def address_params
        params.require(:address).permit(:street_address, :secondary_address, :city, :state, :zip)
      end

      def load_address
        @address = Address.find_by(id: params[:id])
        render json: { error: "Address not found" }, status: :not_found unless @address
      end

      def import_file_param
        params.require(:file)
      end
    end
  end
end
