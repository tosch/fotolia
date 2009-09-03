module Fotolia
  #
  # An interface to the conceptual categories at Fotolia.
  #
  # You should consider using Fotolia::Base#conceptual_categories as shortcut
  # to an instance of this class.
  #
  class ConceptualCategories < Categories
    def initialize(fotolia_client)
      @method = 'getCategories2'
      @klass = ConceptualCategory
      super(fotolia_client)
    end
  end
end