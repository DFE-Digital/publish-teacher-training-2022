require 'rails_helper'

feature 'Application view helpers', type: :helper do
  describe "#formatted_date" do
    it "returns a formatted date" do
      expect(helper.formatted_date('2019-03-05T14:42:34Z')).to eq('5 March 2019')
    end
  end
end
