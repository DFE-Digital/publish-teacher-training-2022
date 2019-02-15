import "../../assets/stylesheets/application.scss";
import { initAll } from "govuk-frontend";
import CookieMessage from "scripts/cookie-banner";

initAll();

var $cookieMessage = document.querySelector('[data-module="cookie-message"]');
new CookieMessage($cookieMessage).init();
