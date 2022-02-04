class SearchController < ApplicationController
  def show
    full_name = params.require(:fullname)
    @entities = SanctionedEntity.where("full_name % :full_name", full_name: full_name).to_a

    render json: { results: @entities }
  end
end
