module Api
  module V1
    class RestaurantsController < ApplicationController
      before_action :set_restaurant, only: %i[show update destroy]

      # GET /api/v1/restaurants
      def index
        @restaurants = Restaurant.all
        render json: @restaurants
      end

      # GET /api/v1/restaurants/:id
      def show
        render json: @restaurant
      end

      # POST /api/v1/restaurants
      def create
        @restaurant = Restaurant.new(restaurant_params)

        if @restaurant.save
          render json: @restaurant, status: :created
        else
          render json: { errors: @restaurant.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/restaurants/:id
      def update
        if @restaurant.update(restaurant_params)
          render json: @restaurant
        else
          render json: { errors: @restaurant.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/restaurants/:id
      def destroy
        @restaurant.destroy
        head :no_content
      end

      private

      def set_restaurant
        @restaurant = Restaurant.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Restaurant not found" }, status: :not_found
      end

      def restaurant_params
        params.require(:restaurant).permit(:name, :address)
      end
    end
  end
end
