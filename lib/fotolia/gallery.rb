module Fotolia
  #
  # Represents a gallery at Fotolia.
  #
  class Gallery
    attr_reader :name, :thumbnail_width, :thumbnail_html_tag, :id, :nb_media,
      :thumbnail_height, :thumbnail_url

    #
    # == Parameters
    # fotolia_client:: A Fotolia::Base object.
    # attributes:: An hash containing the keys 'name', 'id', 'nb_media' and
    #              optional 'thumbnail_width', 'thumbnail_height',
    #              'thumbnail_html_tag' and 'thumbnail_url'.
    #
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
    # Returns the media in this gallery.
    #
    # ==options hash
    # See Fotolia::Base#search
    #
    # ==Returns
    # Fotolia::SearchResultSet
    #
    def media(options = {})
      @fotolia.search(options.merge({:gallery => self}))
    end

    #
    # Deletes the gallery.
    #
    # Requires an authenticated session. The logged in user has to be the owner
    # of the gallery.
    #
    # Not available in Partner API.
    #
    def delete
      raise Fotolia::LoginRequiredError unless @fotolia.logged_in?
      @fotolia.remote_call('deleteUserGallery', @fotolia.session_id, self.id)
    end

    #
    # Add a medium to this gallery. The gallery has to be owned by the logged in
    # user, so this methods requires an authenticated session. See
    # Fotolia::Base#login.
    #
    # Not available in Partner API.
    #
    def << (medium)
      medium.add_to_user_gallery(self)
    end
  end
end
