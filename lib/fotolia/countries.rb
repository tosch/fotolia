module Fotolia
  #
  # Fetches all countries known to Fotolia from its API.
  #
  # You may use Fotolia::Base#countries as shortcut to an instance of this class.
  #
  class Countries
    def initialize(fotolia_client)
      @fotolia = fotolia_client
    end

    #
    # Returns an array of Fotolia::Country objects.
    #
    def find_all
      rsp = @fotolia.remote_call('getCountries', @fotolia.language.id)

      rsp.collect{|c| Fotolia::Country.new(c)}
    end
  end
end