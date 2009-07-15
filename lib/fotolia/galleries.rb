module Fotolia
  class Galleries
    def initialize(fotolia_client)
      @fotolia = fotolia_client
    end

    #
    # Returns public galleries in an array.
    #
    def find_all
      rsp = @fotolia.remote_call('getGalleries', @fotolia.language.id)

      rsp.collect{|g| Fotolia::Gallery.new(@fotolia, g)}
    end

    #
    # Creates a gallery for the logged in user.
    #
    # Requires an authenticated session, see Fotolia::Base#login.
    #
    # Not working with Partner API.
    #
    def create(name)
      raise Fotolia::LoginRequiredError unless @fotolia.logged_in?

      res = @fotolia.remote_call('createUserGallery', @fotolia.session_id, name)

      Fotolia::Gallery.new(@fotolia, {'id' => res['id'], 'name' => name})
    end
  end
end