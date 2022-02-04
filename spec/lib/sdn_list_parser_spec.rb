require 'rails_helper'

RSpec.describe SdnListParser do
  it "parses the test file without errors" do
    test_file = File.read("#{__dir__}/../fixtures/sdn.xml")
    
    models = described_class.parse_from_XML(test_file)

    expect(models.length).to eq(8354)
    expect(models.first).to eq({
       authority: "us_treasury_sdn",
       entity_type: "Entity",
       full_name: "AEROCARIBBEAN AIRLINES",
       list_id: 36,
       remarks: nil,
       sanction_program: "CUBA",
       title: nil,
    })
  end
end
