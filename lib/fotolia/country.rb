module Fotolia
  class Country
    attr_reader :id
    attr_reader :name

    def initialize(attributes)
      @id = attributes['id'].to_i
      @name = attributes['name']
    end
  end
end
