require "rails_helper"

RSpec.describe "routes for authentication", type: :routing do
  describe "production settings" do
    context "dfe_signin" do
      it "default default" do
        expect(get: "/auth/dfe/callback").to route_to("sessions#create")
        expect(get: "/auth/dfe/signout").to route_to("sessions#destroy")
        expect_magic_to_route_to_not_found
        expect_persona_to_route_to_not_found
      end

      it "when opps still defaults", authentication_mode: :opps do
        expect(get: "/auth/dfe/callback").to route_to("sessions#create")
        expect(get: "/auth/dfe/signout").to route_to("sessions#destroy")
        expect_magic_to_route_to_not_found
        expect_persona_to_route_to_not_found
      end
    end

    describe "dfe_signin is down turn on" do
      context "magic_link", authentication_mode: :magic_link do
        it "routes magic" do
          expect(post: "/send_magic_link").to route_to("sessions#send_magic_link")
          expect(get: "/magic_link_sent").to route_to("sessions#magic_link_sent")
          expect(get: "/signin_with_magic_link").to route_to("sessions#create_by_magic")
          expect_dfe_to_route_to_not_found
          expect_persona_to_route_to_not_found
        end
      end
    end
  end

  describe "non-production settings" do
    context "persona", authentication_mode: :persona do
      it "unsafe routes" do
        expect_magic_to_route_to_not_found
        expect_dfe_to_route_to_not_found
        expect(get: "/personas").to route_to("personas#index")
        expect(post: "/auth/developer/callback").to route_to("sessions#create")
        expect(get: "/auth/developer/signout").to route_to("sessions#destroy")
      end
    end
  end
end

def expect_magic_to_route_to_not_found
  expect(post: "/send_magic_link")
    .to route_to(controller: "errors", action: "not_found", path: "send_magic_link")
  expect(get: "/magic_link_sent")
    .to route_to(controller: "errors", action: "not_found", path: "magic_link_sent")
  expect(get: "/signin_with_magic_link")
    .to route_to(controller: "errors", action: "not_found", path: "signin_with_magic_link")
end

def expect_persona_to_route_to_not_found
  expect(get: "/personas")
    .to route_to(controller: "errors", action: "not_found", path: "personas")
  expect(post: "/auth/developer/callback")
    .to route_to(controller: "errors", action: "not_found", path: "auth/developer/callback")
  expect(get: "/auth/developer/signout")
    .to route_to(controller: "errors", action: "not_found", path: "auth/developer/signout")
end

def expect_dfe_to_route_to_not_found
  expect(get: "/auth/dfe/callback")
    .to route_to(controller: "errors", action: "not_found", path: "auth/dfe/callback")
  expect(get: "/auth/dfe/signout")
  .to route_to(controller: "errors", action: "not_found", path: "auth/dfe/signout")
end
