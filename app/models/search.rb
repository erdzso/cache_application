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
class Search < ApplicationRecord
  #
  ### VALIDATIONS

  validates :query, presence: true, length: { maximum: 200.bytes }
  validates :page, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 1000 }

  #
  ### ASSOCIATIONS

  has_many :api_callings, as: :api_caller, dependent: :destroy

  #
  ### INSTANCE METHODS

  def call_api
    client.search
  end

  def process!
    api_calling = api_callings.order(created_at: :asc).last
    if api_calling.nil? || api_calling&.expired?
      new_api_calling = api_callings.build
      save!
      new_api_calling
    else
      api_calling.increase_hit_count!
      api_calling
    end
  end
end
