# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root to: 'searches#search', class_name: 'Search::Movie'
  get '/movie-search' => 'searches#search', as: :movie_search, class_name: 'Search::Movie'
end
