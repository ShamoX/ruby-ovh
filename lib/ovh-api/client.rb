# frozen_string_literal: true

require 'net/https'
require 'uri'
require 'json'
require 'yaml'
require 'digest/sha1'

# Main module
module OVHApi
  # Main class
  class Client
    HOST = 'eu.api.ovh.com'
    attr_reader :application_key, :application_secret, :consumer_key, :host

    def initialize(application_key: nil, application_secret: nil, consumer_key: nil)
      conf = load_config
      @application_key    = application_key || conf['application_key']
      @application_secret = application_secret || conf['application_secret']
      @consumer_key       = consumer_key || conf['consumer_key']
      @host               = conf['host'] || HOST
      @version = 'v1'

      return unless @application_key.nil? || @application_secret.nil?

      raise OVHApiNotConfiguredError,
            'Either instantiate Client.new with application_key and application_secret, ' \
            'or create a YAML file in config/ovh-api.yml with those values set'
    end

    # Request a consumer key
    #
    # @param [Array<Hash<OVHAccessRules>>] access_rules
    #   OVHAccessRules are defined as white list of allowed actions:
    #     - method: GET, POST, PUT, DELETE
    #     - path: the path on which the authorization rules apply to
    # @return [Hash] the JSON response
    def request_consumerkey(access_rules)
      headers = {
        'X-Ovh-Application' => @application_key,
        'Content-type' => 'application/json'
      }

      resp = request_json(:post, '/1.0/auth/credential', nil, access_rules.to_json, headers)

      @consumer_key = resp['consumerKey']
      @consumer_key
    end

    # Helper to make a request to the OVH api then return the body as parsed JSON tree
    #
    # If body cannot be parsed, error is rescued and :body is set to nil.
    #
    # This function raises:
    # - OVHApiNotImplementedError if method is not valid
    # - OVHApiParseError if body cannot be parsed
    #
    # @param method [Symbol]: :get, :post, :put, :delete
    # @param path [String]
    # @param arguments: [Hash]: will be encoded to be URL friendly with URI.encode_www_form and then pass as URL
    #   parameters
    # @param body [String]: function parameters to be JSONified and sent as body in the request
    # @return [Hash] { :resp => [Net::HTTPResponse] response, :body => [Hash|NilClass] (:resp body JSON parsed)  }
    def request_json(method, path, arguments = nil, body = '', headers = nil)
      path = "#{path}?#{URI.encode_www_form(arguments)}" unless arguments.nil?
      resp = request(method, path, body, headers)
      begin
        body = JSON.parse(resp.body)
        { resp: resp, body: body }
      rescue StandardError
        raise OVHApi::OVHApiParseError
      end
    end

    # Make a get request to the OVH api
    #
    # @param path [String]
    # @return [Net::HTTPResponse] response
    def get(path)
      request(path, 'GET', '')
    end

    # Make a post request to the OVH api
    #
    # @param path [String]
    # @param body [String]
    # @return [Net::HTTPResponse] response
    def post(path, body)
      request(path, 'POST', body)
    end

    # Make a put request to the OVH api
    #
    # @param path [String]
    # @param body [String]
    # @return [Net::HTTPResponse] response
    def put(path, body)
      request(path, 'PUT', body)
    end

    # Make a delete request to the OVH api
    #
    # @param path [String]
    # @return [Net::HTTPResponse] response
    def delete(path)
      request(path, 'DELETE', '')
    end

    def request(path, method, body, headers = nil)
      method = validate_method(method)
      http_client = build_http_client
      headers = build_headers(path, method, body) if headers.nil?

      http_client.send_request(method, "/#{@version}#{path}", body, headers)
    end

    def switch_to(version)
      raise OVHApi::OVHApiBadVersionError, 'Version must be :v1 or v2' unless %i[v1 v2].include? version

      @version = version.to_s
    end

    private

    # Generate signature
    #
    # @param path [String]
    # @param method [String]
    # @param timestamp [String]
    # @param body [String]
    #
    def get_signature(path, method, timestamp, body = '')
      if @consumer_key.nil?
        raise OVHApiNotConfiguredError,
              'You cannot make a request without a consumer_key, please use the Client#request_consumerkey method ' \
              'to get one, and validate it with you credential by following the link, and/or save the consumer_key ' \
              'value in the YAML file in config/ovh-api.yml'
      end
      "$1$#{Digest::SHA1.hexdigest("#{application_secret}+#{consumer_key}+#{method}+" \
                                   "https://#{@host}/#{@version}#{path}+#{body}+#{timestamp}")}"
    end

    # load the default configuration.
    def load_config(conf = './config/ovh-api.yml')
      YAML.load_file(conf)
    rescue SystemCallError
      {}
    end

    # Validate method used
    def validate_method(method)
      method_str = method.to_s.upcase
      return method_str if %w[GET POST DELETE PUT].include? method_str

      raise OVHApiNotImplementedError, "#{method_str} is not implemented. Please refere to documentation."
    end

    # Building the http_client for the request
    def build_http_client
      uri = ::URI.parse("https://#{@host}")
      http = ::Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http
    end

    # Building up the header
    def build_headers(path, method, body)
      timestamp = Time.now.to_i

      {
        'Host' => HOST,
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'X-Ovh-Application' => application_key,
        'X-Ovh-Timestamp' => timestamp.to_s,
        'X-Ovh-Signature' => get_signature(path, method, timestamp.to_s, body),
        'x-Ovh-Consumer' => consumer_key
      }
    end
  end
end
