class SearchController < ActionController::Base
  include ActionController::HttpAuthentication::Basic
  http_basic_authenticate_with name: ENV["HTTP_BASIC_USER"],
                               password: ENV["HTTP_BASIC_PASSWORD"],
                               if: -> { ENV["HTTP_BASIC_USER"].present? && ENV["HTTP_BASIC_PASSWORD"].present? }

  def show
    full_name = params.require(:fullname)
    entities = SanctionedEntity.where("full_name % :full_name", full_name: full_name).to_a
    exact_match = entities.map(&:full_name).any? {|entity_full_name| entity_full_name == full_name }

    render json: { exact_match: exact_match, results: entities }
  end
end
