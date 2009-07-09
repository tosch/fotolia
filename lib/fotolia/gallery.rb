module Fotolia
  class Gallery
    attr_reader :name, :thumbnail_width, :thumbnail_html_tag, :id, :nb_media,
      :thumbnail_height, :thumbnail_url

    def initialize(fotolia_client, attributes)
      @fotolia = fotolia_client
      
      @name = attributes['name']
      @thumbnail_width = attributes['thumbnail_width'] if(attributes['thumbnail_width'])
      @thumbnail_html_tag = attributes['thumbnail_html_tag'] if(attributes['thumbnail_html_tag'])
      @id = attributes['id']
      @nb_media = attributes['nb_media']
      @thumbnail_height = attributes['thumbnail_height'] if(attributes['thumbnail_height'])
      @thumbnail_url = attributes['thumbnail_url'] if(attributes['thumbnail_url'])
    end

    #
    # ==options hash
    # See Fotolia::Base#search
    #
    # ==Returns
    # Fotolia::SearchResultSet
    #
    def posts(options = {})
      @fotolia.search(options.merge({:gallery => self}))
    end

    # TODO:: implement function
    def delete
      raise Fotolia::LoginRequiredError unless @fotolia.logged_in?
    end

  end
end
