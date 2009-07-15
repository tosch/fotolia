module Fotolia
  class Tag
    attr_reader :name
    attr_reader :popularity

    def initialize(attributes)
      @name = attributes['name']
      @popularity = attributes['popularity'].to_i
    end

    def to_s
      @name.to_s
    end
  end
end
