class Ruhue::Client
  class << self
    def valid_username?(name)
      name =~ /\A[0-9a-zA-Z]{10,40}\z/
    end
  end

  # Create a Hue client. You’ll need a Hue hub
  # username for this, created via a POST to the
  # /api endpoint. See README for more information.
  #
  # @param [Ruhue] hue
  # @param [String] username
  def initialize(hue, username)
    unless self.class.valid_username?(username)
      raise ArgumentError, "invalid username, must be length 10-40, only numbers and letters"
    end

    @hue = hue
    @username = username
    @last_call = Time.now
  end

  # @return [Ruhue]
  attr_reader :hue

  # @return [String]
  attr_reader :username

  # Register a given username with the Hue hub.
  #
  # @param [String] device_type used as device name
  # @return [Ruhue::Client] if successful
  # @raise [APIError] if failed
  def register(device_type)
    response = hue.post("/api", username: username, devicetype: device_type)
    tap { raise Ruhue::APIError, response.error_messages.join(", ") if response.error? }
  end

  # @return [Boolean] true if username is registered.
  def registered?
    not get("/").error?
  end

  attr_reader :last_call
  attr_writer :last_call
  # enforce rate limiting (hub will start ignoring anything over 30 req/sec)
  def throttle
    elapsed = Time.now - self.last_call
    if elapsed < 0.4
      puts 'throttling...'
      sleep(0.04 - elapsed)
    end
    self.last_call = Time.now
  end

  def get(path)
    throttle
    hue.get(url(path))
  end

  def post(path, data)
    throttle
    hue.post(url(path), data)
  end

  def put(path, data)
    throttle
    hue.put(url(path), data)
  end

  def lights
    get('/lights/').data
  end

  class Light

    # Initialize a Light instance.  This object represents a single light,
    # which can then be manipulated by setting it's attributes.
    # @param client [Ruhue::Client] client parent client name
    # @param i [hash] the lights numerical key on the hub
    # @param data [hash] the data block from a Ruhue::Response
    def initialize(client, i, data)
      @client = client
      @i = i
      @data = data
      @transitiontime = 1 # 1/10 of a second
    end

    attr :i
    attr :client
    attr_reader :data
    attr_writer :data
    attr :transitiontime

    def path(suffix = '')
      "/lights/#{self.i}#{suffix}"
    end

    # @return name (from local cache)
    def name; self.data['name']; end

    # assign the light's name
    def name=(value)
      client.put(path, { :name => value })
      self.data['name'] = value
    end

    # @return state hash (from local cache)
    def state
      self.data['state']
    end

    # update state (passed values are merged into current state)
    # generally easier to use one of the explicit methods below
    def state=(value)
      client.put(path("/state"), {:transitiontime => self.transitiontime}.merge(value))
      self.data['state'].merge!(value) # TODO: always refresh local state from hub?
    end

    # refresh data from the hub
    def refresh!
      self.data = client.get(path).data
    end

    def bri
      self.state['bri']
    end

    # is the lamp on?
    def on?; self.refresh!['state']['on']; end

    # is the lamp off?
    def off?; !self.on?; end

    # turn lamp on
    def on; self.state = { :on => true }; end

    # turn lamp off
    def off; self.state = { :on => false }; end

    # assign brightness
    # @param value [int] value in range 0-255
    def bri=(value); self.state = { :bri => value }; end

    # assign hue
    # @param value [int] value in range 0 < 2**16 - 1
    def hue=(value); self.state = { :hue => value }; end

    # assign saturation
    # @param value [int] value in range 0-255
    def sat=(value); self.state = { :sat => value }; end

    # assign color via CIE xy coordinates
    # @param value [Array] array of two floats in the 0-1 range
    def xy=(value); self.state = { :xy => value }; end

    # convenience method to assign hue and sat at the same time
    # @param [array] value hue and saturation values
    def hs=(value); self.state = { :hue => value[0], :sat => value[1] }; end

    # convenience method to assign hue, sat, and bri at the same time
    # @param color [Color::HSL] takes anything that has h, s, and l methods
    def hsl=(color)
      self.state = { :hue => (color.h * 2**16).floor, :sat => (color.s * 2**8).floor, :bri => (color.l * 2**8).floor }
    end

    # assign the alert state (blinking)
    # @param value [String] one of 'none', 'select' (blink once), 'lselect' (blink continually)
    def alert=(value)
      self.state = { :alert => value }
    end

    # flash the light once
    def select
      self.alert = 'select'
    end

    # flash the light a bunch of times (~20)
    # @param flag [Bool] optional, use false/nil to stop a previous alert
    def lselect(flag = true)
      self.alert = flag ? 'lselect' : 'none'
    end

  end

  # Get a Ruhue::Client::Light instance for given light number
  #
  # @param [int] i
  def light(i)
    Light.new(self, i, get("/lights/#{i}").data) # TODO: cache by index/name?
  end

  protected

  def url(path)
    "/api/#{username}/#{path.sub(/\A\//, "")}"
  end
end
