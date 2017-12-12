require 'omniauth-oauth2'

# this OmniAuth-Strategy uses the Keyrock Identity Management
# see http://catalogue.fiware.org/enablers/identity-management-keyrock
# The server url is from the public FIWARE Lab instance.
# Ubicación (inside Docker): /opt/gitlab/embedded/service/gitlab-rails/lib/omni_auth/strategies/

module OmniAuth
  module Strategies
    class FilabStrategy < OmniAuth::Strategies::OAuth2
      option :name, "filab"
      option :client_options, {
          site: 'https://account.lab.fiware.org',
          authorize_url: 'https://account.lab.fiware.org/oauth2/authorize/',
          token_url: 'https://account.lab.fiware.org/oauth2/token'
      }

      def raw_info
        @raw_info ||= access_token.get('/user?access_token=', params: { access_token: access_token.token }).parsed
      end

      extra do
        { raw_info => raw_info}
      end

      def build_access_token
        Rails.logger.debug "Omniauth build access token"
        options.token_params.merge!(:headers => {'Authorization' => basic_auth_header })
        super
      end

      def basic_auth_header
        "Basic " + Base64.strict_encode64("#{options[:client_id]}:#{options[:client_secret]}")
      end

      uid do
          puts "8.- Mensaje: #{raw_info['id']}"
          raw_info['id']
      end

      info do
        {
          name: raw_info['displayName'],
          nickname: raw_info['id'],
          email: raw_info['email'],
          roles: raw_info['roles'],
          organizations: raw_info['organizations']
        }
      end

    end
  end
end

