# frozen_string_literal: true

module OVHApi
  class OVHApiError < RuntimeError; end
  class OVHApiNotConfiguredError < OVHApiError; end
  class OVHApiNotImplementedError < OVHApiError; end
  class OVHApiParseError < OVHApiError; end
end
