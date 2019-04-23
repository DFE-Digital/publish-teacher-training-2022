class User < Base
  custom_endpoint :accept_transition_screen, on: :member, request_method: :patch
end
