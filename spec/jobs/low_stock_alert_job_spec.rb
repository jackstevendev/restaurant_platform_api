require 'rails_helper'

RSpec.describe LowStockAlertJob, type: :job do
  include ActiveJob::TestHelper

  describe '#perform' do
    it 'calls Inventory::LowStockAlertService' do
      expect(Inventory::LowStockAlertService).to receive(:call)
      described_class.perform_now
    end

    it 'enqueues the job in the :default queue' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(described_class).on_queue('default')
    end
  end
end
