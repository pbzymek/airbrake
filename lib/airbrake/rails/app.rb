module Airbrake
  module Rails
    # App is a wrapper around Rails.application and Rails::Engine.
    #
    # @since v9.0.3
    # @api private
    class App
      Route = Struct.new(:path, :controller, :action)

      def routes
        @routes ||= app_routes.merge(engine_routes).flat_map do |(engine_name, routes)|
          routes.map { |rails_route| build_route(engine_name, rails_route) }
        end
      end

      private

      def app_routes
        # Engine name is nil because this is default (non-engine) routes.
        { nil => ::Rails.application.routes.routes.routes }
      end

      def engine_routes
        ::Rails::Engine.subclasses.flat_map.with_object({}) do |engine, hash|
          next if (eng_routes = engine.routes.routes.routes).none?

          hash[engine.engine_name] = eng_routes
        end
      end

      def build_route(engine_name, rails_route)
        engine_prefix = engine_name
        engine_prefix += '#' if engine_prefix

        Route.new(
          "#{engine_prefix}#{rails_route.path.spec}",
          rails_route.defaults[:controller],
          rails_route.defaults[:action]
        )
      end
    end
  end
end
