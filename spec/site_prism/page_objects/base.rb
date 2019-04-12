module PageObjects
  class Base < SitePrism::Page
    class << self
      def objects
        @objects ||= {}
      end
    end

    def objects
      self.objects
    end
  end
end
