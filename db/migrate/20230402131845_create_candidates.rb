# frozen_string_literal: true

class CreateCandidates < ActiveRecord::Migration[7.0]
  def change
    create_table :candidates do |t|
      t.string :name
      t.string :email
      t.integer :experience_time
      t.string :focus

      t.timestamps
    end
  end
end
