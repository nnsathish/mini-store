require "json"
require "mini_store/pricing_rules"

module MiniStore
  class Product
    attr_reader :code, :name, :price, :quantity, :pricing_rule

    DATA_PATH = File.join(
      File.dirname(__dir__), "../data", 'products.json'
    ).freeze

    def initialize(code:, name:, price:)
      @code = code
      @name = name
      @price = price
      @quantity = 1 # Anti-Pattern?!
    end

    def self.all
      @products ||= begin
        file = File.read(DATA_PATH)
        products = JSON.parse(file, symbolize_names: true)
        products.map { |p| Product.new(p) }
      end
    end

    def self.all_by_code
      @products_by_code ||= self.all.inject({}) do |hsh, p|
        hsh.merge(p.code.to_sym => p)
      end
    end

    def self.find(code)
      self.all_by_code[code.to_sym].dup
    end

    def set_pricing_rule!(rule)
      @pricing_rule = PricingRules.for(rule)
    end

    def increment_quantity!
      @quantity += 1
    end

    def rule_price
      return total_price unless @pricing_rule

      discount = @pricing_rule.compute_discount(self)
      total_price - discount
    end

    def total_price
      self.price * self.quantity
    end
  end
end
