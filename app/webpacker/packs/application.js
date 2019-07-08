import "../stylesheets/application.scss";
import { initAll } from "govuk-frontend";
import CookieMessage from "scripts/cookie-banner";
import FormCheckLeave from "scripts/form-check-leave";

initAll();

var $cookieMessage = document.querySelector('[data-module="cookie-message"]');
new CookieMessage($cookieMessage).init();

var $copyWarningMessage = document.querySelector(
  '[data-copy-course="warning"]'
);
if ($copyWarningMessage) {
  var $enrichmentForm = document.querySelector('[data-qa="enrichment-form"]');

  if ($enrichmentForm) {
    $enrichmentForm.addEventListener("submit", function() {
      window.onbeforeunload = null;
    });
  }

  window.onbeforeunload = function() {
    return "You have unsaved changes, are you sure you want to leave?";
  };
}

const $form = document.querySelector('[data-module="form"]');
new FormCheckLeave($form).init();
