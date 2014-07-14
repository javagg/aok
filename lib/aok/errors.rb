module Aok
  module Errors

    class AokError < RuntimeError
      attr_accessor :http_status, :http_headers, :error, :error_description

      def initialize(error="unknown_error", desc="An unknown error occurred.", code=500)
        @error = error
        @error_description = desc
        @http_status = code
        @http_headers = {
          'Content-Type' => 'application/json',
          'Cache-Control' => 'no-store'
        }
      end

      def body
        {
          'error' => error,
          'error_description' => error_description
        }.to_json
      end

    end

    class Unauthorized < AokError
      def initialize(desc='Bad credentials', type='Bearer', realm="oauth")
        super()
        @http_status = 401
        @error = 'unauthorized'
        @error_description = desc
        @http_headers = http_headers.merge({
          'WWW-Authenticate' =>
            %Q{#{type} realm="#{realm}", error="#{error}", error_description="#{error_description}"}
        })
      end
    end

    class InvalidClient < Unauthorized
      def initialize(type, realm)
        super
        @error_description = "Invalid client identifier supplied."
        @error = 'invalid_client'
      end
    end

    class AccessDenied < AokError
      def initialize(desc='Access Denied')
        super()
        @http_status = 403
        @error = 'access_denied'
        @error_description = desc
      end
    end

    class InvalidToken < Unauthorized
      def initialize(reason='could not decode')
        super("Invalid token (#{reason})")
        @error = 'invalid_token'
      end
    end

    class NotImplemented < AokError
      def initialize(desc='You have reached a stub API endpoint that has not yet been implemented in AOK.')
        super()
        @http_status = 501
        @error = 'Not Implemented'
        @error_description = desc
      end
    end

    class NotFound < AokError
      def initialize(desc='Not found.')
        super()
        @http_status = 404
        @error = 'not_found'
        @error_description = desc
      end
    end

    class ScimNotFound < NotFound
      def initialize(desc='Not found.')
        super(desc)
        @error = 'scim_resource_not_found'
      end

      def body
        {
          'error' => error,
          'message' => error_description
        }.to_json
      end
    end

    class ScimFilterError < AokError
      def initialize(desc='Invalid SCIM filter')
        super('scim_filter_error', desc, 400)
      end
    end

    class ScimGroupInvalid < AokError
      def initialize(desc='Invalid group')
        super('scim_resource_invalid', desc, 400)
      end

      def body
        {
          'error' => error,
          'message' => error_description
        }.to_json
      end
    end

    class NoGettingCredentials < Unauthorized
      def initialize(desc="Credentials must be sent by (one of methods): [POST]")
        super desc
      end
    end

  end

end
