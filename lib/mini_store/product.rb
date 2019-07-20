module MiniStore
  class Product
    attr_reader :code, :name, :price

    def initialize(code:, name:, price:)
      @code = code
      @name = name
      @price = price
    end

    def self.find(code)
      MiniStore.products_by_code[code.to_sym]
    end
  end
end
