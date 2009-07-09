module Fotolia
  class RepresentativeCategories < Categories
    def initialize(fotolia_client)
      @method = 'getCategories1'
      @klass = RepresentativeCategory
      super(fotolia_client)
    end
  end
end