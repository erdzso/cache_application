# frozen_string_literal: true

# == Schema Information
#
# Table name: api_callings
#
#  id              :bigint           not null, primary key
#  api_caller_type :string(255)      not null
#  api_caller_id   :bigint           not null
#  expired_at      :datetime
#  hit_count       :integer          not null
#  state           :integer          not null
#  result          :text(65535)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require 'rails_helper'

RSpec.describe ApiCalling, type: :model do
  describe '(DB COLUMNS)' do
    it { is_expected.to have_db_column(:api_caller_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:api_caller_type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:expired_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:hit_count).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:state).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:result).of_type(:text) }
  end

  describe '(VALIDATIONS)' do
    it { is_expected.to validate_numericality_of(:hit_count) }
  end

  describe '(ASSOCIATIONS)' do
    it { is_expected.to belong_to(:api_caller) }
  end
end
