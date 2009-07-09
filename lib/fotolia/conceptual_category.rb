module Fotolia
  class ConceptualCategory < Category
    def child_categories
      @fotolia.conceptual_categories.find(self)
    end
  end
end
