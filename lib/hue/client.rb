class Hue::Client
  class << self
    def valid_username?(name)
      name =~ /\A[0-9a-zA-Z]{10,40}\z/
    end
  end

  # Create a Hue client. You’ll need a Hue hub
  # username for this, created via a POST to the
  # /api endpoint. See README for more information.
  #
  # @param [Hue] hue
  # @param [String] username
  def initialize(hue, username)
    unless self.class.valid_username?(username)
      raise ArgumentError, "invalid username, must be length 10-40, only numbers and letters"
    end

    @hue = hue
    @username = username
  end

  # @return [Hue]
  attr_reader :hue

  # @return [String]
  attr_reader :username

  # Register a given username with the Hue hub.
  #
  # @param [String] device_type used as device name
  # @return [Hue::Client] if successful
  # @raise [APIError] if failed
  def register(device_type)
    response = hue.post("/api", username: username, devicetype: device_type)
    tap { raise Hue::APIError, response.error_messages.join(", ") if response.error? }
  end

  # @return [Boolean] true if username is registered.
  def registered?
    not get("/").error?
  end

  def get(path)
    hue.get(url(path))
  end

  def post(path, data)
    hue.post(url(path), data)
  end

  def put(path, data)
    hue.put(url(path), data)
  end

  protected

  def url(path)
    "/api/#{username}/#{path.sub(/\A\//, "")}"
  end
end
