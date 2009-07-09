module Fotolia
  class RepresentativeCategory < Category
    def child_categories
      @fotolia.representative_categories.find(self)
    end
  end
end
