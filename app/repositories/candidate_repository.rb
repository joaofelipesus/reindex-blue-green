# frozen_string_literal: true

class CandidateRepository
  # NOTE: defines the host of elasticsearch, we use elasticsearch instead of localhost due to docker network.
  ELASTICSEARCH_HOST = 'http://elasticsearch:9200/'.freeze

  # NOTE: defines the mapping with candidate attributes and its types.
  INDEX_MAPPING = {
    mappings: {
      properties: {
        name: { type: "text" },
        email: { type: "text" },
        experience_time: { type: "integer" },
        focus: { type: "text" }
      }
    }
  }.freeze

  # Create an index with received name.
  #
  # @param index_name [String] index_name
  def create_index(index_name)
    response = conn.put(index_name) do |req|
      req.body = INDEX_MAPPING.to_json
    end

    return :ok if response.status == 200

    response.body
  end

  # Index candidate on received index.
  #
  # @param candidate [Candidate] candidate object.
  # @param index_name [String] index which received candidate will be indexed.
  def index_candidate(candidate, index_name)
    response = conn.put("#{index_name}/_doc/#{candidate.id}") do |req|
      req.body = {
        name: candidate.name,
        email: candidate.email,
        experience_time: candidate.experience_time,
        focus: candidate.focus
      }.to_json
    end

    return 'Candidate indexed' if response.status == 201 || response.status == 200

    response.body
  end

  private

  def conn
    Faraday.new(
      url: ELASTICSEARCH_HOST,
      headers: {'Content-Type' => 'application/json'}
    )
  end
end
