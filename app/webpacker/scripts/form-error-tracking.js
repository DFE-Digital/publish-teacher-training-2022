export function triggerFormAnalytics(category, action, label) {
  ga("send", "event", {
    eventCategory: category,
    eventAction: action,
    eventLabel: label
  });
}
