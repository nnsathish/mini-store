require "json"

module MiniStore
  class Product
    attr_reader :code, :name, :price, :quantity

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

    def increment_quantity!
      @quantity += 1
    end

    def discounted_price(pricing_rule = nil)
      pricing_rule ||= {}
      return total_price unless valid_pricing_rule?(pricing_rule)

      discount = compute_discount(pricing_rule)
      total_price - discount
    end

    def total_price
      self.price * self.quantity
    end

    private

    # EnhancementTip: Can be refactored when we add a PricingRule class
    def valid_pricing_rule?(rule)
      !((rule[:every] || rule[:min]) && rule[:discount]).nil?
    end

    # ideally, should be delegated to Discounts::Every or Discounts::Min
    def compute_discount(rule)
      factor = discount_factor(rule)

      if rule[:every].to_i > 0
        (self.quantity / rule[:every].to_i) * factor
      elsif rule[:min].to_i <= self.quantity
        self.quantity * factor
      else
        0.0
      end
    end

    def discount_factor(rule)
      case rule[:discount]
      when /\A\d+%\Z/
        self.price * (rule[:discount].to_i / 100.0)
      else
        rule[:discount].to_i
      end
    end
  end
end
