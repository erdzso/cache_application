# frozen_string_literal: true

# :nodoc:
class CreateApiCallings < ActiveRecord::Migration[7.0]
  def change
    create_table :api_callings do |t|
      t.belongs_to :api_caller, polymorphic: true, null: false
      t.datetime :expired_at
      t.integer :hit_count, null: false
      t.integer :state, null: false
      t.text :result

      t.timestamps
    end
  end
end
