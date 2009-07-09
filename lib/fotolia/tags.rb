module Fotolia
  class Tags
    def initialize(fotolia_client)
      @fotolia = fotolia_client
    end

    def most_searched
      self.find('Searched')
    end

    def most_used
      self.find('Used')
    end

    protected

    def find(type)
      rsp = @fotolia.remote_call('getTags', @fotolia.language.id, type)

      rsp.collect{|t| Fotolia::Tag.new(t)}
    end
  end
end