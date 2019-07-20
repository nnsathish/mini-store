require "mini_store/discounts"

module MiniStore
  module PricingRules
    RULE_CLASS_MAP = {
      every: :Every,
      min: :Minimum
    }

    def self.for(rule)
      rule ||= {}
      rule_class = RULE_CLASS_MAP[rule[:type]]
      return unless rule_class
      const_get(rule_class).new(rule)
    end

    class Base
      attr_reader :value, :discount

      def initialize(rule)
        @value = rule[:value].to_i
        @discount = Discounts.for(rule[:discount])
      end

      def compute_discount(product)
        discount_factor = @discount.factor(product)
        self.factor(product) * discount_factor
      end
    end

    class Every < Base
      def factor(product)
        return 0.0 unless value > 0
        product.quantity / value
      end
    end

    class Minimum < Base
      def factor(product)
        return 0.0 if product.quantity < value
        product.quantity
      end
    end
  end
end
