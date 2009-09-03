module Fotolia
  #
  # Represents a representative category at Fotolia.
  #
  class RepresentativeCategory < Category
    #
    # Returns an array of ConceptualCategory objects which are children of this
    # category.
    #
    def child_categories
      @fotolia.representative_categories.find(self)
    end

    #
    # Searches for media in this category. For the options hash, see
    # Fotolia::Base#search.
    #
    # Returns a Fotolia::SearchResultSet.
    #
    def media(options = {})
      @fotolia.search(options.merge({:representative_category => self}))
    end
  end
end
