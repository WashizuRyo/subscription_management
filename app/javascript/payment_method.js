import jQuery from "jquery";
window.$ = jQuery;

document.addEventListener("turbo:load", () => {
  initTooltip();

  $(document).on("click", '[id^="edit_button_"]', function () {
    const buttonId = $(this).attr("id");
    const methodId = buttonId.replace("edit_button_", "");

    $(`#payment_method_${methodId}`).hide();
    $(`#edit_form_${methodId}`).show();
    document.getElementById(`edit_provider_${methodId}`).focus();
  });

  $(document).on("click", ".cancel-edit", function () {
    const methodId = $(this).data("method-id");

    $(`#payment_method_${methodId}`).show();
    $(`#edit_form_${methodId}`).hide();
  });
});

function initTooltip() {
  const tooltipTriggerList = document.querySelectorAll(
    '[data-bs-toggle="tooltip"]'
  );
  const tooltipList = [...tooltipTriggerList].map(
    (tooltipTriggerEl) => new bootstrap.Tooltip(tooltipTriggerEl)
  );
}
