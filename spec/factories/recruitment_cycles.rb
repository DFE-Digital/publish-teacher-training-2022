FactoryBot.define do
  factory :recruitment_cycle, class: Hash do
    sequence(:id)
    year { '2019' }

    initialize_with do
      data_attributes = attributes.except(:id)
      JSONAPIMockSerializable.new(
        id,
        'recruitment_cycles',
        attributes: data_attributes
      )
    end
  end
end
