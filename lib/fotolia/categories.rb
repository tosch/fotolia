module Fotolia
  class Categories
    def initialize(fotolia_client)
      @fotolia = fotolia_client
    end

    def find(category = nil)
      raise 'You have to use ConceptualCategories or RepresentativeCategories!' unless(@method && @klass)

      k = if(category) then category.id else :root end

      if(@categories && @categories[k]) # check if categories have been loaded already
        @categories[k] # use cached categories
      else
        # get cats from fotolia
        res = if(category && (category.kind_of?(String) || category.kind_of?(Fixnum)))
          @fotolia.remote_call(@method, @fotolia.language.id, category.to_i)
        elsif(category)
          @fotolia.remote_call(@method, @fotolia.language.id, category.id.to_i)
        else
          @fotolia.remote_call(@method, @fotolia.language.id)
        end

        @categories = Hash.new unless(@categories)

        @categories[k] = res.collect{|c| @klass.new(@fotolia, {'key' => c.first, 'parent_category' => category}.merge(c.last))}
      end
    end

    def root_level
      self.find
    end
  end
end