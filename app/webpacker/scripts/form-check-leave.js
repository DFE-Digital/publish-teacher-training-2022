function FormCheckLeave($module) {
  this.$module = $module;
}

FormCheckLeave.prototype.init = function() {
  const $form = this.$module;

  if ($form) {
    const $originalFormContent = encodeURIComponent(
      Array.from(new FormData($form))
    );

    window.onbeforeunload = function(event) {
      const $updatedFormContent = encodeURIComponent(
        Array.from(new FormData($form))
      );

      // Used to handle browsers that use legacy onbeforeunload
      // https://developer.mozilla.org/en-US/docs/Web/API/Window/beforeunload_event
      if ($updatedFormContent !== $originalFormContent) {
        event.preventDefault();
        event.returnValue =
          "You have unsaved changes, are you sure you want to leave?";
        return "You have unsaved changes, are you sure you want to leave?";
      }
    };
  }
};

export default FormCheckLeave;
