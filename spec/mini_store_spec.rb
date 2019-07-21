RSpec.describe MiniStore do
  describe 'VERSION' do
    it { expect(MiniStore::VERSION).not_to be nil }
  end

  describe '.log' do
    subject { MiniStore.log('Test message', level) }
    before { stub_const('MiniStore::LOGGER', Logger.new(IO::NULL)) }
    context 'with valid level' do
      let(:level) { :info }
      it { is_expected.to be_truthy }
    end
    context 'with invalid level' do
      let(:level) { :extreme_warning }
      it { expect { subject }.to raise_exception(NoMethodError) }
    end
  end
end
