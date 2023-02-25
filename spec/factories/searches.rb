# frozen_string_literal: true

# == Schema Information
#
# Table name: searches
#
#  id         :bigint           not null, primary key
#  type       :string(255)      not null
#  query      :string(255)      not null
#  page       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :search do
    query { 'MyString' }
    page { 1 }
  end

  factory :movie_search, class: 'Search::Movie', parent: :search do
  end
end
