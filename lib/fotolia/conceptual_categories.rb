module Fotolia
  class ConceptualCategories < Categories
    def initialize(fotolia_client)
      @method = 'getCategories2'
      @klass = ConceptualCategory
      super(fotolia_client)
    end
  end
end