# MiniStore

A simple store with a billing interface based on predefined product pricing
and discount rules. Uses JSON as data store.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mini_store'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mini_store

## Usage

To execute sample test cases, run:

    $ bin/mini_store

For customized testing:

```ruby
pricing_rules = { VOUCHER: { type: :every, value: 2, discount: '100%' }, TSHIRT: { type: :min, value: 3, discount: 1 } }
co = MiniStore::Checkout.new(pricing_rules)
co.scan('VOUCHER')
co.scan("VOUCHER")
co.scan("TSHIRT")
price = co.total
```
