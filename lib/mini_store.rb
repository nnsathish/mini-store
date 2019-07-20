require "mini_store/version"
require "mini_store/checkout"
require "mini_store/product"
require "json"

module MiniStore
  class Error < StandardError; end

  PRODUCTS_JSON_PATH = File.join(
    File.dirname(__dir__), 'data', 'products.json'
  ).freeze

  def self.products
    @products ||= begin
      file = File.read(PRODUCTS_JSON_PATH)
      products = JSON.parse(file, symbolize_names: true)
      products.map { |p| Product.new(p) }
    end
  end

  def self.products_by_code
    @products_by_code ||= self.products.inject({}) do |hsh, p|
      hsh.merge(p.code.to_sym => p)
    end
  end
end
