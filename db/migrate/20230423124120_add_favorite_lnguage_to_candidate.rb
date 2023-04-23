# frozen_string_literal: true

class AddFavoriteLnguageToCandidate < ActiveRecord::Migration[7.0]
  def change
    add_column :candidates, :favorite_language, :string, default: nil

    # Set an value to :favorite_language attribute
    Candidate.all.find_each { |c| c.update(favorite_language: %w[elixir ruby javascript].sample) }
  end
end
