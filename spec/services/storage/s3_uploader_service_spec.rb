require 'rails_helper'

RSpec.describe Storage::S3UploaderService do
  let(:file_content) { "Sample PDF binary content" }
  let(:destination_path) { "invoices/test-order-123.pdf" }

  describe '.call' do
    it 'returns the deterministic AWS S3 URL for the destination path' do
      url = described_class.call(file_content, destination_path)

      expect(url).to start_with('https://restaurant-platform-invoices.s3.us-east-1.amazonaws.com/invoices/test-order-123.pdf')
    end

    it 'sanitizes leading slashes in destination paths' do
      url = described_class.call(file_content, "/invoices/leading-slash.pdf")

      expect(url).to eq('https://restaurant-platform-invoices.s3.us-east-1.amazonaws.com/invoices/leading-slash.pdf')
    end
  end
end
