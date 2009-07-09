module Fotolia
  class Galleries
    def initialize(fotolia_client)
      @fotolia = fotolia_client
    end

    def find_all
      rsp = @fotolia.remote_call('getGalleries', @fotolia.language.id)

      rsp.collect{|g| Fotolia::Gallery.new(g)}
    end
  end
end