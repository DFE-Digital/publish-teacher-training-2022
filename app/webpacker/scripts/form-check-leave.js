function FormCheckLeave($module) {
  this.$module = $module;
  this.$changed = false;
}

FormCheckLeave.prototype.init = function() {
  const $form = this.$module;

  if (!$form) return;

  this.action($form);
};

FormCheckLeave.prototype.action = function($form) {
  let $changed = this.$changed;
  $form.addEventListener("input", () => ($changed = true));
  $form.addEventListener("submit", () => (window.onbeforeunload = null));

  window.onbeforeunload = function() {
    if ($changed) {
      event.preventDefault();
      event.returnValue =
        "You have unsaved changes, are you sure you want to leave?";
      return "You have unsaved changes, are you sure you want to leave?";
    }
  };
};

export default FormCheckLeave;
