require 'rails_helper'

RSpec.describe "Healthchecks", type: :request do
  describe "GET /index" do
    it "always returns 200 with an empty body" do
      get "/healthcheck"
      expect(response.code).to eq("200")
      expect(response.body).to be_blank
    end
  end
end
