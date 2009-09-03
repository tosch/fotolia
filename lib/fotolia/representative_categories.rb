module Fotolia
  #
  # An interface to the representative categories at Fotolia.
  #
  # You should consider using Fotolia::Base#representative_categories as
  # shortcut to an instance of this class.
  #
  class RepresentativeCategories < Categories
    def initialize(fotolia_client)
      @method = 'getCategories1'
      @klass = RepresentativeCategory
      super(fotolia_client)
    end
  end
end