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
require 'rails_helper'

RSpec.describe Search, type: :model do
  describe '(DB COLUMNS)' do
    it { is_expected.to have_db_column(:type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:query).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:page).of_type(:integer).with_options(null: false) }
  end

  describe '(VALIDATIONS)' do
    it { is_expected.to validate_presence_of(:query) }
    it { is_expected.to validate_length_of(:query).is_at_most(200.bytes) }
    it { is_expected.to validate_presence_of(:page) }
    it { is_expected.to validate_numericality_of(:page).only_integer.is_greater_than(0).is_less_than_or_equal_to(1000) }
  end

  describe '(ASSOCIATIONS)' do
    it { is_expected.to have_many(:api_callings) }
  end
end
