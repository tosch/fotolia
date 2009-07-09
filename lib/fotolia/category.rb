module Fotolia
  class Category
    attr_reader :id, :name, :parent_category, :key

    def initialize(fotolia_client, attributes)
      @fotolia = fotolia_client
      @id = attributes['id'].to_i
      @name = attributes['name']
      @parent_category = attributes['parent_category']
      @key = attributes['key']
    end
  end
end
