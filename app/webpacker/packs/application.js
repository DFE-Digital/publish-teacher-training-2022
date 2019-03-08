import '../stylesheets/application.scss';
import Turbolinks from 'turbolinks';
import { initAll } from 'govuk-frontend';
import CookieMessage from 'scripts/cookie-banner';

Turbolinks.start();

document.addEventListener('turbolinks:load', function () {
  initAll();

  var $cookieMessage = document.querySelector('[data-module="cookie-message"]');
  new CookieMessage($cookieMessage).init();
});
