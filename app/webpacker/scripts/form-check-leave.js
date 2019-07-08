function FormCheckLeave($module) {
  this.$module = $module;
  this.$data = "";
}

FormCheckLeave.prototype.data = function() {
  const $form = this.$module;
  return Array.from(new FormData($form), e =>
    e.map(encodeURIComponent).join("=")
  ).join("&");
};

FormCheckLeave.prototype.init = function() {
  const $form = this.$module;
  let $data = this.$data;

  if (!$form) return;

  $data = this.data();

  this.action($form, $data);
};

FormCheckLeave.prototype.action = function($form, $data) {
  const $changes = this.data();
  $form.addEventListener("submit", () => (window.onbeforeunload = null));

  window.onbeforeunload = function() {
    event.preventDefault();
    event.preventDefault();
    event.returnValue =
      "You have unsaved changes, are you sure you want to leave?";
    return "You have unsaved changes, are you sure you want to leave?";
  };
};

export default FormCheckLeave;
