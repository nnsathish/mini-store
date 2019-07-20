module MiniStore
  module Discounts
    def self.for(discount)
      klass = case discount
      when Percent::REGEX
        Percent
      else
        Fixed
      end
      klass.new(discount)
    end

    # Cleanup: Move to seperate files when they tend to grow
    class Base
      attr_reader :discount

      def initialize(discount)
        @discount = discount.to_i
      end
    end

    class Fixed < Base
      def factor(product)
        discount
      end
    end
 
    class Percent < Base
      REGEX = /\A\d+%\Z/.freeze

      def factor(product)
        product.price * (discount / 100.0)
      end
    end
  end
end
