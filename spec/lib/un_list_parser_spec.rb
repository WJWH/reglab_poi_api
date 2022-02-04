require 'rails_helper'

RSpec.describe UnListParser do
  it "parses the test file without errors" do
    test_file = File.read("#{__dir__}/../fixtures/consolidated.xml")
    
    models = described_class.parse_from_XML(test_file)

    expect(models.length).to eq(965)
    expect(models.first).to eq({
      authority: "un_sc_consolidated",
      entity_type: "Individual",
      full_name: "RI, WON HO ",
      list_id: 6908555,
      remarks: "Ri Won Ho is a DPRK Ministry of State Security Official stationed in Syria supporting KOMID.\n ",
      sanction_program: "DPRK",
    })
  end
end
