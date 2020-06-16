export default class FormCheckLeave {
  constructor($module) {
    if(!$module) { return }
    const $form = $module

    let $change = false

    $form.addEventListener("submit", () => {
      window.onbeforeunload = null
    })

    $form.addEventListener("change", () => {
      $change = true
    })

    window.onbeforeunload = function(event) {
      if ($change) {
        // Used to handle browsers that use legacy onbeforeunload
        // https://developer.mozilla.org/en-US/docs/Web/API/Window/beforeunload_event
        event.preventDefault();
        event.returnValue =
          "You have unsaved changes, are you sure you want to leave?";
        return "You have unsaved changes, are you sure you want to leave?";
      }
    }
  }
}

//
// function FormCheckLeave($module) {
//   this.$module = $module;
// }
//
// FormCheckLeave.prototype.init = function() {
//   const $form = this.$module;
//   let $change = false;
//
//   if ($form) {
//     $form.addEventListener("submit", function() {
//       window.onbeforeunload = null;
//     });
//
//     $form.addEventListener("change", function() {
//       $change = true;
//     });
//
//     window.onbeforeunload = function(event) {
//       if ($change) {
//         // Used to handle browsers that use legacy onbeforeunload
//         // https://developer.mozilla.org/en-US/docs/Web/API/Window/beforeunload_event
//         event.preventDefault();
//         event.returnValue =
//           "You have unsaved changes, are you sure you want to leave?";
//         return "You have unsaved changes, are you sure you want to leave?";
//       }
//     };
//   }
// };
//
// export default FormCheckLeave;
