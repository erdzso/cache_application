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
FactoryBot.define do
  factory :api_calling do
    assocition { :search }
    expired_at { Time.zone.now }
    state { 1 }
    hit_count { 1 }
  end
end
