class SeoController < ApplicationController
  def show
    @search_term = params[:search_term]
  end
end
