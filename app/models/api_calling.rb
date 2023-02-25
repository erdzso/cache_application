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
class ApiCalling < ApplicationRecord
  STATES = {
    created: 1,
    succeeded: 2,
    failed: 3
  }.freeze

  enum state: STATES

  serialize :result, JSON

  #
  ### VALIDATIONS

  validates :hit_count, numericality: { only_integer: true }
  validates :state, inclusion: { in: STATES.with_indifferent_access.keys }

  #
  ### ASSOCIATIONS

  belongs_to :api_caller, polymorphic: true, inverse_of: :api_callings

  #
  ### CALLBACKS

  before_validation :set_needed_attributes, if: :new_record?
  before_save :call_api, if: :new_record?

  #
  ### INSTANCE METHDOS

  def set_needed_attributes
    send(:state=, :created) unless state
    send(:hit_count=, 0) unless hit_count
  end

  def expired?
    expired_at && (expired_at < Time.zone.now)
  end

  def increase_hit_count!
    with_lock do
      update!(hit_count: hit_count + 1)
    end
  end

  def call_api
    result = api_caller.call_api
    send(:result=, result)
    send(:state=, result[:code] == 200 ? :succeeded : :failed)
    send(:expired_at=, Time.zone.now + expiration_time)
  end

  def expiration_time
    ApiCallingConfiguration.instance.expiration_time.seconds
  end
end
