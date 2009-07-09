module Fotolia
  class Tag
    attr_reader :tag
    attr_reader :popularity

    def initialize(attributes)
      @tag = attributes['tag']
      @popularity = attributes['popularity'].to_i
    end
  end
end
