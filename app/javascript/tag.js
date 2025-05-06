import jQuery from "jquery";
window.$ = jQuery;

document.addEventListener("turbo:load", () => {
  const newTagForm = $("#new_tag_form");

  $(document).on("click", ".edit-tag-button", function () {
    const tagId = $(this).data("tag-id");
    const tagForm = $(`#edit_tag_form_${tagId}`);
    const input = document.getElementById(`tag_name_${tagId}`);
    tagForm.show("fast");
    newTagForm.hide("fast");
    focusInputToEnd(input);
  });

  $(document).on("click", "#cancel_edit_button", function () {
    const tagId = $(this).data("tag-id");
    const tagForm = $(`#edit_tag_form_${tagId}`);
    tagForm.hide("fast");
    newTagForm.show("fast");
  });
});

function focusInputToEnd(input) {
  const value = input.value;
  input.value = "";
  input.value = value;
  input.focus();
}
