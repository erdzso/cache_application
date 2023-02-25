# frozen_string_literal: true

# :nodoc:
class SearchesController < ApplicationController
  before_action :load_search_class

  def search
    if query_param
      with_at_most_one_retry(ActiveRecord::RecordNotUnique) do
        @search = @search_class.find_or_initialize_by(query: query_param, page: page_param)
        @api_calling = @search.process!
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:error] = e
  end

  private

  def load_search_class
    @search_class = params[:class_name].constantize
  end

  def query_param
    params.permit(:query).fetch(:query, nil)
  end

  def page_param
    params.permit(:page).fetch(:page, 1)
  end

  def with_at_most_one_retry(exception, &block)
    retried = false
    begin
      block.call
    rescue exception
      raise if retried

      retried = true
      retry
    end
  end
end
