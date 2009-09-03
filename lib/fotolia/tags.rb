module Fotolia
  #
  # Interface to tags at Fotolia.
  #
  # Use Fotolia::Base#tags as shortcut to an instance of this class.
  #
  class Tags
    def initialize(fotolia_client)
      @fotolia = fotolia_client
    end

    #
    # Returns an array of the most searched tags at Fotolia.
    #
    # The tags should be in the language the used Fotolia::Base object is set to.
    #
    def most_searched
      self.find('Searched')
    end

    #
    # Returns an array of the most used tags in media at Fotolia.
    #
    # The tags should be in the language the used Fotolia::Base object is set to.
    #
    def most_used
      self.find('Used')
    end

    protected

    def find(type) #:nodoc:
      rsp = @fotolia.remote_call('getTags', @fotolia.language.id, type)

      rsp.collect{|t| Fotolia::Tag.new(t)}
    end
  end
end