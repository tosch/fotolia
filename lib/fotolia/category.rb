module Fotolia
  #
  # Base class for ConceptualCategory and RepresentativeCategory.
  #
  class Category
    # <Integer> The category's id at Fotolia
    attr_reader :id
    # <String> The category's name at Fotolia. Should be translated to the language the used Fotolia::Base object is set to.
    attr_reader :name
    # <Category> The parent of this category or nil if any.
    attr_reader :parent_category
    # <String> Don't know what this attribute means, but Fotolia's API delivers it...
    attr_reader :key

    def initialize(fotolia_client, attributes)
      @fotolia = fotolia_client
      @id = attributes['id'].to_i
      @name = attributes['name']
      @parent_category = attributes['parent_category']
      @key = attributes['key']
    end
  end
end
