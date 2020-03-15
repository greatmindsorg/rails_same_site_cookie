module RailsSameSiteCookie
  class Middleware

    COOKIE_SEPARATOR = "\n".freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      regex = RailsSameSiteCookie.configuration.user_agent_regex
      set_cookie = headers['Set-Cookie']
      if (regex.nil? or regex.match(env['HTTP_USER_AGENT'])) and not (set_cookie.nil? or set_cookie.strip == '')
        cookies = set_cookie.split(COOKIE_SEPARATOR)
        ssl = Rack::Request.new(env).ssl?

        cookies.each do |cookie|
          next if cookie == '' or cookie.nil?
          if ssl and not cookie =~ /;\s*secure/i
            cookie << '; Secure'
          end

          unless cookie =~ /;\s*samesite=/i
            cookie << '; SameSite=None'
          end

        end

        headers['Set-Cookie'] = cookies.join(COOKIE_SEPARATOR)
      end

      [status, headers, body]
    end

  end
end
