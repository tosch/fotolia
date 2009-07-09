module Fotolia
  class Color
    attr_reader :id
    attr_reader :name

    def initialize(attributes)
      @id = attributes[:id]
      @name = attributes[:name]
    end
  end
end
