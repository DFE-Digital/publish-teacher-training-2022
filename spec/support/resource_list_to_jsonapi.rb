def resource_list_to_jsonapi(resource_list, **opts)
  renderer = JSONAPI::Serializable::Renderer.new

  jsonapi = renderer.render(
    resource_list,
    class: {
      # This tells the renderer what serializers to use. The key is going
      # to be the name of the class as a symbol, and the value is the
      # serializer class.
      Course: CourseSerializer,
      Provider: ProviderSerializer,
      RecruitmentCycle: RecruitmentCycleSerializer,
      Site: SiteSerializer,
      SiteStatus: SiteStatusSerializer,
      User: UserSerializer,
      ProviderSuggestion: ProviderSuggestionSerializer,
      Subject: SubjectSerializer,
      AccessRequest: AccessRequestSerializer,
      Organisation: OrganisationSerializer,
      Allocation: AllocationSerializer,
      AllocationUplift: AllocationUpliftSerializer,
      UserNotificationPreferences: UserNotificationPreferencesSerializer,
      Contact: ContactSerializer,
    },
    include: opts[:include],
    meta: opts[:meta],
  )

  # Somehow, the JSONAPI Serializer reifies these objects as 'nil' if they
  # include an id with them. No idea why, so this hack is going to have to
  # suffice for now.
  jsonapi[:included]&.each { |data| data[:attributes].delete :id }
  jsonapi
end
