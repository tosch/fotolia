module Fotolia
  class Countries
    def initialize(fotolia_client)
      @fotolia = fotolia_client
    end

    def find_all
      rsp = @fotolia.remote_call('getCountries', @fotolia.language.id)

      rsp.collect{|c| Fotolia::Country.new(c)}
    end
  end
end