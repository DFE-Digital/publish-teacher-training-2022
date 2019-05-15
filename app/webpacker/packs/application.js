import "../stylesheets/application.scss";
import { initAll } from "govuk-frontend";
import CookieMessage from "scripts/cookie-banner";

initAll();

var $cookieMessage = document.querySelector('[data-module="cookie-message"]');
new CookieMessage($cookieMessage).init();

var $copyWarningMessage = document.querySelector('[data-copy-course="warning"]');
if ($copyWarningMessage) {
  window.onbeforeunload = function() {
    return 'You have unsaved changes, are you sure you want to leave?'
  }
}
