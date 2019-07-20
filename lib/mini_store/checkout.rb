require "mini_store/product"

module MiniStore
  class Checkout
    attr_reader :pricing_rules, :products

    DEFAULT_PRICING_RULES = {
      VOUCHER: { every: 2, discount: '100%' },
      TSHIRT: { min: 3, discount: 1 }
    }.freeze

    def initialize(pricing_rules = nil)
      @pricing_rules = pricing_rules || DEFAULT_PRICING_RULES
      # parse_pricing_rules
      @products = {}
    end

    def scan(product_code)
      product = Product.find(product_code)
      MiniStore.log('Product not found', :error) and return unless product
      add_product(product)
    end

    def total
      @total ||= begin
        @products.sum do |code, product|
          pricing_rule = @pricing_rules[code.to_sym]
          product.discounted_price(pricing_rule)
        end
      end
    end

    private

    def add_product(product)
      if @products[product.code]
        @products[product.code].increment_quantity!
      else
        @products[product.code] = product
      end
      @total = nil # recompute total
    end
  end
end
