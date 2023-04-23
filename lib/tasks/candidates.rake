# frozen_string_literal: true

namespace :candidates do
  desc 'Create candidates'
  task seed: :environment do
    5_000.times do |index|
      Candidate.create!(
        name: Faker::Name.name,
        email: Faker::Internet.email,
        experience_time: rand(1..10),
        focus: %w[backend frontend fullstack].sample,
        favorite_language: %w[elixir ruby javascript].sample
      )

      puts "#{index + 1} of 5000"
    end
  end

  desc 'Index candidates'
  task mass_indexation: :environment do
    index_name = 'candidates'

    puts 'Creating index ...'
    CandidateRepository.new.create_index(index_name)
    puts 'Index created'

    Candidate.all.find_each.with_index do |candidate, index|
      CandidateRepository.new.index_candidate(candidate, index_name)

      puts "#{index + 1} of #{Candidate.count}"
    end
  end
end
