module Fotolia
  class ConceptualCategory < Category
    def child_categories
      @fotolia.conceptual_categories.find(self)
    end

    #
    # Searches for media in this category. For the options hash, see
    # Fotolia::Base#search.
    #
    # Returns a Fotolia::SearchResultSet.
    #
    def media(options = {})
      @fotolia.search(options.merge({:conceptual_category => self}))
    end
  end
end
