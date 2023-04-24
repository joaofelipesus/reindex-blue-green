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
    splitted_date_time = DateTime.current.to_s.split('T')
    date_values = splitted_date_time.first.split('-')
    time_values = splitted_date_time.last.split(':')
    index_name = "candidates_#{date_values[0]}_#{date_values[1]}_#{date_values[2]}_#{time_values[0]}_#{time_values[1]}"

    puts 'Creating index ...'
    CandidateRepository.new.create_index(index_name)
    puts 'Index created'

    CandidateRepository.new.create_alias(CandidateRepository::PRODUCTION_ALIAS, index_name)

    Candidate.all.find_each.with_index do |candidate, index|
      CandidateRepository.new.index_candidate(candidate, index_name)

      puts "#{index + 1} of #{Candidate.count}"
    end
  end
end
