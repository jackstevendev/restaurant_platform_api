require 'rails_helper'

RSpec.describe Report, type: :model do
  describe 'creation' do
    it 'creates a valid report with factory' do
      report = create(:report)
      expect(report).to be_persisted
      expect(report.status).to eq('pending')
    end
  end
end
