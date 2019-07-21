RSpec.describe MiniStore::Checkout do
  describe 'DEFAULT_PRICING_RULES' do
    subject(:default_rules) { MiniStore::Checkout::DEFAULT_PRICING_RULES }
    it do
      expect(default_rules[:TSHIRT]).not_to be_nil
      expect(default_rules[:VOUCHER]).not_to be_nil
      expect(default_rules[:MUG]).to be_nil
    end
  end

  describe '#initialize' do
    subject(:co) { MiniStore::Checkout.new(pricing_rules) }
    context 'with default pricing rules' do
      let(:pricing_rules) { nil }
      it do
        expect(co.pricing_rules[:TSHIRT]).not_to be_nil
        expect(co.products).to eq({})
      end
    end
    context 'with custom pricing rules' do
      let(:pricing_rules) { {} }
      it do
        expect(co.pricing_rules).to eq({})
        expect(co.products).to eq({})
      end
    end
  end

  describe '#scan' do
    let!(:co) { MiniStore::Checkout.new }
    subject(:product) { co.scan(code) }
    context 'with invalid product_code' do
      let(:code) { 'TESSTSGGS' }
      before { stub_const('MiniStore::LOGGER', Logger.new(IO::NULL)) }
      it do
        is_expected.to be_nil
        expect(co.products).to eq({})
      end
    end
    context 'with valid product_code' do
      let(:code) { 'VOUCHER' }
      it do
        is_expected.not_to be_nil
        expect(product.code).to eq(code)
        expect(product.quantity).to eq(1)
      end
      it do
        expect(product.pricing_rule).to be_instance_of(MiniStore::PricingRules::Every)
      end
    end
    context 'when scanning a scanned product' do
      let(:code) { 'VOUCHER' }
      before { co.scan(code) }
      it do
        expect(product.code).to eq(code)
        expect(product.quantity).to eq(2)
      end
    end
  end

  describe '#total' do
    let(:co) { MiniStore::Checkout.new(rules) }
    let!(:tshirt_price) { MiniStore::Product.find(:TSHIRT).price }
    let!(:voucher_price) { MiniStore::Product.find(:VOUCHER).price }
    let!(:mug_price) { MiniStore::Product.find(:MUG).price }
    subject { co.total }
    context 'with no scanned items' do
      let(:rules) { {} }
      it { is_expected.to eq(0.0) }
    end
    context 'with default pricing rules' do
      let(:rules) { nil }
      context 'with no applicable discount' do
        before do
          %w(VOUCHER TSHIRT TSHIRT MUG MUG MUG).each { |c| co.scan(c) }
        end
        it do
          expect(co.products.size).to eq(3)
          total = voucher_price + (2 * tshirt_price) + (3 * mug_price)
          is_expected.to eq(total)
        end
      end
      context 'with 2_for_1 discount for voucher' do
        before do
          %w(VOUCHER TSHIRT VOUCHER VOUCHER TSHIRT VOUCHER VOUCHER).each { |c| co.scan(c) }
        end
        it do
          expect(co.products.size).to eq(2)
          total = (3 * voucher_price) + (2 * tshirt_price)
          is_expected.to eq(total)
        end
      end
      context 'with 3_or_more 1-euro discount for tshirt' do
        before do
          %w(TSHIRT TSHIRT MUG TSHIRT).each { |c| co.scan(c) }
        end
        it do
          expect(co.products.size).to eq(2)
          total = mug_price + (3 * (tshirt_price - 1))
          is_expected.to eq(total)
        end
      end
    end
    context 'with customized pricing rules' do
      let(:rules) {
        {
          MUG: { type: :every, value: 3, discount: 2.0 },
          TSHIRT: { type: :min, value: 2, discount: '50%' },
          VOUCHER: { type: :invalid }
        }
      }
      context 'with no applicable discount' do
        before do
          %w(VOUCHER TSHIRT VOUCHER MUG MUG).each { |c| co.scan(c) }
        end
        it do
          total = tshirt_price + (2 * voucher_price) + (2 * mug_price)
          is_expected.to eq(total)
        end
      end
      context 'with 3-for-2-euro discount for mug' do
        before do
          %w(MUG MUG TSHIRT MUG VOUCHER MUG).each { |c| co.scan(c) }
        end
        it do
          total = tshirt_price + voucher_price + ( mug_price * 4 - 2)
          is_expected.to eq(total)
        end
      end
      context 'with 2_or_more 50% discount for tshirt' do
        before do
          %w(TSHIRT TSHIRT VOUCHER TSHIRT).each { |c| co.scan(c) }
        end
        it do
          total = voucher_price + (tshirt_price / 2 * 3)
          is_expected.to eq(total)
        end
      end
      context 'with multiple applicable discounts' do
        before do
          %w(MUG MUG MUG TSHIRT MUG TSHIRT MUG MUG).each { |c| co.scan(c) }
        end
        it do
          total = (mug_price * 6 - (2 * 2)) + (tshirt_price / 2 * 2)
          is_expected.to eq(total)
        end
      end
    end
  end
end
