module MiniStore
  class Checkout
    attr_reader :pricing_rules, :products

    DEFAULT_PRICING_RULES = {
      VOUCHER: { every: 2, discount: '100%' },
      TSHIRT: { min: 3, discount: 1 }
    }.freeze

    def initialize(pricing_rules = nil)
      @pricing_rules = pricing_rules || DEFAULT_PRICING_RULES
      parse_pricing_rules
      @products = []
    end

    def scan(product_code)
      Pro
    end

    def total
    end

    private

    def parse_pricing_rules
      puts pricing_rules.inspect
    end
  end
end
