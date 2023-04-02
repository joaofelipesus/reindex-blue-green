# frozen_string_literal: true

namespace :candidates do
  desc 'Create candidates'
  task seed: :environment do
    5_000.times do |index|
      Candidate.create!(
        name: Faker::Name.name,
        email: Faker::Internet.email,
        experience_time: rand(1..10),
        focus: %w[backend frontend fullstack].sample
      )

      puts "#{index + 1} of 5000"
    end
  end
end
