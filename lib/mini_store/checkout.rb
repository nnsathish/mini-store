require "mini_store/product"

module MiniStore
  class Checkout
    attr_reader :pricing_rules, :products

    DEFAULT_PRICING_RULES = {
      VOUCHER: { type: :every, value: 2, discount: '100%' },
      TSHIRT: { type: :min, value: 3, discount: 1 }
    }.freeze

    def initialize(pricing_rules = nil)
      @pricing_rules = pricing_rules || DEFAULT_PRICING_RULES
      @products = {}
    end

    def scan(product_code)
      product = Product.find(product_code)
      MiniStore.log('Product not found', :error) and return unless product
      add_product(product)
    end

    def total
      @total ||= begin
        @products.sum do |_, product|
          product.rule_price
        end
      end
    end

    private

    def add_product(product)
      if @products[product.code]
        @products[product.code].increment_quantity!
      else
        product.set_pricing_rule!(@pricing_rules[product.code.to_sym])
        @products[product.code] = product
      end
      @total = nil # recompute total
    end
  end
end
