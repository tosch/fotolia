module Fotolia
  class Colors
    def initialize(fotolia_client)
      @fotolia = fotolia_client
    end

    def find_all(parent_color = nil)
      rsp = if(parent_color.kind_of?(Fotolia::Color))
        @fotolia.remote_call('getColors', parent_color.id)
      elsif(parent_color)
        @fotolia.remote_call('getColors', parent_color.to_i)
      else
        @fotolia.remote_call('getColors')
      end

      ret = Array.new

      rsp['colors'].each_value do |color_response|
        ret << Fotolia::Color.new(:id => color_response['id'].to_i, :name => color_response['name'])
      end

      ret
    end
  end
end