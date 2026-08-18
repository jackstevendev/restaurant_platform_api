require 'rails_helper'

RSpec.describe 'Api::V1::Orders', type: :request do
  let(:customer) { create(:customer) }
  let(:restaurant) { create(:restaurant) }
  let(:product1) { create(:product, restaurant: restaurant, price: 25.00, name: 'Steak') }
  let!(:inventory1) { create(:inventory_item, product: product1, quantity: 10) }
  let(:product2) { create(:product, restaurant: restaurant, price: 8.00, name: 'Salad') }
  let!(:inventory2) { create(:inventory_item, product: product2, quantity: 5) }

  describe 'GET /api/v1/orders' do
    let!(:order1) { create(:order, customer: customer, status: :pending) }
    let!(:order2) { create(:order, customer: customer, status: :paid) }

    it 'returns list of orders serialized with JSONAPI format' do
      get '/api/v1/orders'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.length).to eq(2)

      order_ids = json.map { |item| item.dig('data', 'id') }
      expect(order_ids).to include(order1.id.to_s, order2.id.to_s)
    end
  end

  describe 'GET /api/v1/orders/:id' do
    let(:order) { create(:order, customer: customer, status: :completed, total: 33.00) }
    let!(:order_item) { create(:order_item, order: order, product: product1, price: 25.00, quantity: 1) }

    context 'when order exists' do
      it 'returns the order serialized' do
        get "/api/v1/orders/#{order.id}"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.dig('data', 'id')).to eq(order.id.to_s)
        expect(json.dig('data', 'attributes', 'status')).to eq('completed')
        expect(json.dig('data', 'attributes', 'total')).to eq('33.0')
      end
    end

    context 'when order does not exist' do
      it 'returns 404 not found' do
        get "/api/v1/orders/#{SecureRandom.uuid}"

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json).to have_key('error')
      end
    end
  end

  describe 'POST /api/v1/restaurants/:restaurant_id/orders/place_order' do
    let(:valid_params) do
      {
        order: {
          customer_id: customer.id,
          order_items: [
            { product_id: product1.id, quantity: 2 },
            { product_id: product2.id, quantity: 1 }
          ]
        }
      }
    end

    context 'when order placement is successful' do
      it 'creates the order, reduces stock, and returns 201 with serialized order' do
        expect {
          post "/api/v1/restaurants/#{restaurant.id}/orders/place_order",
               params: valid_params,
               as: :json
        }.to change(Order, :count).by(1).and change(OrderItem, :count).by(2)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json['message']).to eq('Order placed successfully')
        expect(json['order']).to be_present
        expect(json.dig('order', 'data', 'attributes', 'total')).to eq('58.0') # (25*2) + (8*1)

        expect(inventory1.reload.quantity).to eq(8)
        expect(inventory2.reload.quantity).to eq(4)
      end
    end

    context 'when inventory is insufficient' do
      let(:insufficient_inventory_params) do
        {
          order: {
            customer_id: customer.id,
            order_items: [
              { product_id: product1.id, quantity: 20 } # only 10 available
            ]
          }
        }
      end

      it 'returns 422 unprocessable entity and rolls back changes' do
        expect {
          post "/api/v1/restaurants/#{restaurant.id}/orders/place_order",
               params: insufficient_inventory_params,
               as: :json
        }.not_to change(Order, :count)

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Insufficient inventory for Steak')
        expect(inventory1.reload.quantity).to eq(10)
      end
    end

    context 'when restaurant is not found' do
      it 'returns 404 not found' do
        post "/api/v1/restaurants/#{SecureRandom.uuid}/orders/place_order",
             params: valid_params,
             as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when ordering a product belonging to another restaurant' do
      let(:other_restaurant) { create(:restaurant) }
      let(:other_product) { create(:product, restaurant: other_restaurant) }
      let!(:other_inventory) { create(:inventory_item, product: other_product, quantity: 10) }

      let(:cross_restaurant_params) do
        {
          order: {
            customer_id: customer.id,
            order_items: [
              { product_id: other_product.id, quantity: 1 }
            ]
          }
        }
      end

      it 'returns 404 not found' do
        post "/api/v1/restaurants/#{restaurant.id}/orders/place_order",
             params: cross_restaurant_params,
             as: :json

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Product not found for this restaurant')
      end
    end

    context 'when required order parameter is missing' do
      it 'returns 400 bad request' do
        post "/api/v1/restaurants/#{restaurant.id}/orders/place_order",
             params: {},
             as: :json

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
