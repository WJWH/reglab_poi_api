require 'rails_helper'

RSpec.describe "Searches", type: :request do
  describe "POST /search" do
    context "bad requests" do
      it 'raises ParameterMissing if the fullname parameter is not present' do
        headers = { "CONTENT_TYPE" => "application/json" }
        expect { 
          post '/search', :params => '{}', :headers => headers
        }.to raise_error ActionController::ParameterMissing
      end
    end

    context "good requests" do
      before(:all) { SanctionedEntity.create!(full_name: "KIM, Jong Un", list_id: 123, entity_type: "Individual") }
      let(:headers) {{ "CONTENT_TYPE" => "application/json" }}

      it "finds exact matches" do
        post '/search', :params => { fullname: "KIM, Jong Un" }.to_json, :headers => headers

        expect(response.code).to eq("200")

        parsed_body = JSON.parse(response.body)
        expect(parsed_body["results"].size).to eq(1)
        expect(parsed_body["results"].first["full_name"]).to eq("KIM, Jong Un")
      end

      it "finds close matches" do
        post '/search', :params => { fullname: "KIM, Jong Il" }.to_json, :headers => headers

        expect(response.code).to eq("200")

        parsed_body = JSON.parse(response.body)
        expect(parsed_body["results"].size).to eq(1)
        expect(parsed_body["results"].first["full_name"]).to eq("KIM, Jong Un")
      end

      it "finds matches with just a fragment of the name" do
        post '/search', :params => { fullname: "KIM" }.to_json, :headers => headers

        expect(response.code).to eq("200")

        parsed_body = JSON.parse(response.body)
        expect(parsed_body["results"].size).to eq(1)
        expect(parsed_body["results"].first["full_name"]).to eq("KIM, Jong Un")
      end

      it "does not find very loose matches" do
        post '/search', :params => { fullname: "RUTTE, Mark" }.to_json, :headers => headers

        expect(response.code).to eq("200")
        expect(JSON.parse(response.body)).to eq({"results" => []})
      end
    end
  end
end
