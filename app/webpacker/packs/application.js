require.context("govuk-frontend/govuk/assets");

import "../stylesheets/application.scss";
import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import { initAll } from "govuk-frontend";
import FormCheckLeave from "scripts/form-check-leave";
import { triggerFormAnalytics } from "scripts/form-error-tracking";
import initAutocomplete from "scripts/autocomplete";
import initLocationsMap from "scripts/locations-map";

initAll();

window.initLocationsMap = initLocationsMap;

const $form = document.querySelector('[data-module="form-check-leave"]');
new FormCheckLeave($form).init();

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

if (typeof ga === "function") {
  const $formErrorSummary = document.querySelector(
    '[data-ga-event-form="error"]'
  );
  const $formSuccessSummary = document.querySelector(
    '[data-ga-event-form="success"]'
  );

  if ($formErrorSummary) {
    const $formErrorMessages = $formErrorSummary.querySelectorAll(
      "[data-error-message]"
    );

    triggerFormAnalytics("form", "form-submitted", "form-error");

    $formErrorMessages.forEach(function($errorMessage) {
      triggerFormAnalytics(
        "form",
        "form-error-message",
        $errorMessage.getAttribute("data-error-message")
      );
    });
  } else if ($formSuccessSummary) {
    triggerFormAnalytics("form", "form-submitted", "form-success");
  }
}

try {
  const $autocomplete = document.getElementById("provider-autocomplete");
  const $input = document.getElementById("course_accredited_body");
  if ($autocomplete) {
    initAutocomplete($autocomplete, $input);
  }
} catch (err) {
  console.error("Failed to initialise provider autocomplete:", err);
}
