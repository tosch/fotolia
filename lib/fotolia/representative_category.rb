module Fotolia
  class RepresentativeCategory < Category
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
