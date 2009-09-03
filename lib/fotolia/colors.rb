module Fotolia
  #
  # Class fetching colors known to Fotolia's API.
  #
  # You should use Fotolia::Base#colors as shortcut instead of creating own
  # instances.
  #
  class Colors
    def initialize(fotolia_client)
      @fotolia = fotolia_client
    end

    #
    # Fetches colors from Fotolia's API and returns them as Array of
    # Fotolia::Color objects.
    #
    # Colors at Fotolia may have children. Not passing anything to this method
    # returns all root level colors. Passing a Fotolia::Color object returns
    # its children.
    #
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