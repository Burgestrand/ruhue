class Hue::Response
  # @param [HTTPI::Response] response
  def initialize(response)
    @response = response
    @data = JSON.load(response.body)
  end

  # @return [String] body
  attr_reader :response

  # @return [Array, Hash] data
  attr_reader :data

  # @return [Boolean] true if the response is an error.
  def error?
    data.is_a?(Array) and data.any? { |hash| hash.has_key?("error") }
  end

  # @return [Array<String>, nil] array of error messages and their address, nil if no error.
  def error_messages
    data.map { |hash| "#{hash["error"]["address"]}: #{hash["error"]["description"]}" } if error?
  end
end
