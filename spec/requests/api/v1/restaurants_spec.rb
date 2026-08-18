require 'rails_helper'

RSpec.describe 'Api::V1::Restaurants', type: :request do
  describe 'GET /api/v1/restaurants' do
    let!(:restaurant1) { create(:restaurant, name: 'Bistro One') }
    let!(:restaurant2) { create(:restaurant, name: 'Trattoria Two') }

    it 'returns a list of restaurants' do
      get '/api/v1/restaurants'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
      names = json.map { |r| r['name'] }
      expect(names).to include('Bistro One', 'Trattoria Two')
    end

    it 'caches the response in Rails.cache' do
      memory_store = ActiveSupport::Cache.lookup_store(:memory_store)
      allow(Rails).to receive(:cache).and_return(memory_store)

      get '/api/v1/restaurants'

      expect(Rails.cache.exist?('restaurants')).to be true
    end
  end

  describe 'GET /api/v1/restaurants/:id' do
    let(:restaurant) { create(:restaurant, name: 'Gourmet Place', address: '123 Main St') }

    context 'when restaurant exists' do
      it 'returns the restaurant details' do
        get "/api/v1/restaurants/#{restaurant.id}"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['id']).to eq(restaurant.id)
        expect(json['name']).to eq('Gourmet Place')
        expect(json['address']).to eq('123 Main St')
      end
    end

    context 'when restaurant does not exist' do
      it 'returns 404 not found with error message' do
        get "/api/v1/restaurants/#{SecureRandom.uuid}"

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Restaurant not found')
      end
    end
  end

  describe 'POST /api/v1/restaurants' do
    context 'with valid parameters' do
      let(:valid_attributes) do
        {
          restaurant: {
            name: 'New Pizzeria',
            address: '456 Elm St'
          }
        }
      end

      it 'creates a new restaurant and returns 201' do
        expect {
          post '/api/v1/restaurants', params: valid_attributes, as: :json
        }.to change(Restaurant, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['name']).to eq('New Pizzeria')
        expect(json['address']).to eq('456 Elm St')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        {
          restaurant: {
            name: '',
            address: '456 Elm St'
          }
        }
      end

      it 'does not create a restaurant and returns 422' do
        expect {
          post '/api/v1/restaurants', params: invalid_attributes, as: :json
        }.not_to change(Restaurant, :count)

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Name can't be blank")
      end
    end

    context 'with missing required parameter root' do
      it 'returns 400 bad request' do
        post '/api/v1/restaurants', params: {}, as: :json

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json).to have_key('error')
      end
    end
  end

  describe 'PATCH /api/v1/restaurants/:id' do
    let(:restaurant) { create(:restaurant, name: 'Old Name', address: 'Old Address') }

    context 'with valid parameters' do
      it 'updates the restaurant and returns 200' do
        patch "/api/v1/restaurants/#{restaurant.id}",
              params: { restaurant: { name: 'Updated Name', address: 'New Address' } },
              as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['name']).to eq('Updated Name')
        expect(json['address']).to eq('New Address')
        expect(restaurant.reload.name).to eq('Updated Name')
      end
    end

    context 'with invalid parameters' do
      it 'returns 422 unprocessable entity' do
        patch "/api/v1/restaurants/#{restaurant.id}",
              params: { restaurant: { name: '' } },
              as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Name can't be blank")
      end
    end

    context 'when restaurant does not exist' do
      it 'returns 404 not found' do
        patch "/api/v1/restaurants/#{SecureRandom.uuid}",
              params: { restaurant: { name: 'Any Name' } },
              as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/restaurants/:id' do
    let!(:restaurant) { create(:restaurant) }

    context 'when restaurant exists' do
      it 'destroys the restaurant and returns 204 no content' do
        expect {
          delete "/api/v1/restaurants/#{restaurant.id}"
        }.to change(Restaurant, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when restaurant does not exist' do
      it 'returns 404 not found' do
        delete "/api/v1/restaurants/#{SecureRandom.uuid}"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
