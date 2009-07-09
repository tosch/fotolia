module Fotolia
  class Gallery
    attr_reader :name, :thumbnail_width, :thumbnail_html_tag, :id, :nb_media,
      :thumbnail_height, :thumbnail_url

    def initialize(attributes)
      @name = attributes['name']
      @thumbnail_width = attributes['thumbnail_width'].to_i
      @thumbnail_html_tag = attributes['thumbnail_html_tag']
      @id = attributes['id'].to_i
      @nb_media = attributes['nb_media']
      @thumbnail_height = attributes['thumbnail_height'].to_i
      @thumbnail_url = attributes['thumbnail_url']
    end
  end
end
