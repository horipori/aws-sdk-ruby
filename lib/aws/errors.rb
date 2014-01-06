module Aws
  module Errors

    # The base class for all errors returned by an Amazon Web Service.
    # All ~400 level client errors and ~500 level server errors are raised
    # as service errors.  This indicates it was an error returned from the
    # service and not one generated by the client.
    class ServiceError < RuntimeError

      # @param [Seahorse::Client::RequestContext] context
      # @param [String] message
      def initialize(context = nil, message = nil)
        if context.is_a?(String)
          message = context
        else
          @context = context
        end
        super(message)
      end

      # @return [Seahorse::Client::RequestContext] The context of the request
      #   that triggered the remote service to return this error.
      attr_reader :context

    end

    # Various plugins perform client-side checksums of responses.
    # This error indicates a checksum failed.
    class ChecksumError < RuntimeError; end

    # Raised when a {Service} is constructed an no suitable API
    # version is found based on configuration.
    class NoSuchApiVersionError < RuntimeError; end

    # Raised when a {Service} is constructed and credentials are not
    # set, or the set credentials are empty.
    class MissingCredentialsError < RuntimeError; end

    # Raised when a {Service} is constructed and region is not specified.
    class MissingRegionError < RuntimeError; end

    # This module is mixed into another module, providing dynamic
    # error classes.  Error classes all inherit from {ServiceError}.
    #
    #     # creates and returns the class
    #     Aws::S3::Errors::MyNewErrorClass
    #
    # Since the complete list of possible AWS errors returned by services
    # is not known, this allows us to create them as needed.  This also
    # allows users to rescue errors by class without them being concrete
    # classes beforehand.
    #
    # @api private
    module DynamicErrors

      def const_missing(constant)
        const_set(constant, Class.new(ServiceError))
      end

      # Given the name of a service and an error code, this method
      # returns an error class (that extends {ServiceError}.
      #
      #     Aws::S3::Errors.error_class('NoSuchBucket').new
      #     #=> #<Aws::S3::Errors::NoSuchBucket>
      #
      # @api private
      def error_class(contstant)
        if constants.include?(contstant.to_sym)
          const_get(contstant)
        else
          const_set(contstant, Class.new(ServiceError))
        end
      end

    end
  end
end
