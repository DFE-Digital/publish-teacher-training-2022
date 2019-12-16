FactoryBot.define do
  factory :organisation do
    skip_create

    transient do
      providers { [] }
      users { [] }
    end

    sequence(:id)
    name { "Organisation" }
    nctl_ids { [] }

    after :build do |organisation, evaluator|
      # Necessary gubbins necessary to make JSONAPIClient's associations work.
      organisation.providers = []
      evaluator.providers.each do |provider|
        organisation.providers << provider
      end

      organisation.users = []
      evaluator.users.each do |user|
        organisation.users << user
      end
    end
  end
end
