require 'rails_helper'

RSpec.describe "Api::Tickets", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/api/tickets/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/api/tickets/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/api/tickets/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/api/tickets/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/api/tickets/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /assign" do
    it "returns http success" do
      get "/api/tickets/assign"
      expect(response).to have_http_status(:success)
    end
  end

end
