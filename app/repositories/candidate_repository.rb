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
        focus: { type: "text" },
        favorite_language: { type: "text" }
      }
    }
  }.freeze

  # Alias names
  PRODUCTION_ALIAS = 'candidates_index'
  PROCESSING_ALIAS = 'candidates_processing'

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

  # Create an alias with received name and index.
  #
  # @param alias_name [String] alias name.
  # @param index_name [String] index name.
  def create_alias(alias_name, index_name)
    response = conn.post(
      '_aliases',
      {
        actions: [
          {
            add: {
              index: index_name,
              alias: alias_name
            }
          }
        ]
      }.to_json
    )

    return 'Alias created' if response.status == 200

    response.body
  end

  # Switch indexes pointed by production and processing alias, and at the end removes old production index.
  def switch_production_alias
    production_index_name = get_index_name(PRODUCTION_ALIAS)
    processing_index_name = get_index_name(PROCESSING_ALIAS)

    point_alias_to_index(alias_name: PRODUCTION_ALIAS, index_name: processing_index_name)
    remove_index_pointer(alias_name: PRODUCTION_ALIAS, index_name: production_index_name)
    remove_index_pointer(alias_name: PROCESSING_ALIAS, index_name: processing_index_name)

    drop_index(production_index_name)
  end

  private

  # Return the index name that received alias points.
  #
  # @param alias_name [String] alias name.
  def get_index_name(alias_name)
    response_body = conn.get("#{alias_name}/_alias").body
    JSON.parse(response_body).keys.first
  end

  # Points received alias to received index.
  #
  # @param alias_name [String] alias name.
  # @param index_name [String] index name.
  def point_alias_to_index(alias_name:, index_name:)
    conn.post(
      '_aliases',
      {
        actions: [
          {
            add: {
              index: index_name,
              alias: alias_name
            }
          }
        ]
      }.to_json
    )
  end

  # Remove index pointer from received alias.
  #
  # @param alias_name [String] alias name.
  # @param index_name [String] index name.
  def remove_index_pointer(alias_name:, index_name:)
    conn.post(
      '_aliases',
      {
        actions: [
          {
            remove: {
              index: index_name,
              alias: alias_name
            }
          }
        ]
      }.to_json
    )
  end

  # Drop received index.
  #
  # @param index_name [String] index name.
  def drop_index(index_name)
    conn.delete(index_name)
  end

  def conn
    Faraday.new(
      url: ELASTICSEARCH_HOST,
      headers: {'Content-Type' => 'application/json'}
    )
  end
end
