# frozen_string_literal: true

# :nodoc:
class CreateSearches < ActiveRecord::Migration[7.0]
  def change
    create_table :searches do |t|
      t.string :type, null: false
      t.string :query, null: false
      t.integer :page, null: false

      t.timestamps

      t.index %i[type query page], unique: true
    end
  end
end
