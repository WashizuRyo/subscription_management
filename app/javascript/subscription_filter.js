document.addEventListener("DOMContentLoaded", () => {
  const filterColumnSelect = document.querySelector(
    'select[name="q[filter_column]"]'
  );
  const textFilterFields = document.getElementById("text_filter_fields");
  const dateFilterFields = document.getElementById("date_filter_fields");
  const dateFilterEndField = document.getElementById("date_filter_end_field");
  const dateFilterPatternSelect = document.querySelector(
    'select[name="q[date_filter_pattern]"]'
  );

  function updateFilterFields() {
    const selectedColumn = filterColumnSelect.value;

    if (selectedColumn === "name" || selectedColumn === "plan_name") {
      textFilterFields.style.display = "block";
      dateFilterFields.style.display = "none";
    } else if (
      selectedColumn === "price" ||
      selectedColumn === "start_date" ||
      selectedColumn === "end_date" ||
      selectedColumn === "billing_date"
    ) {
      textFilterFields.style.display = "none";
      dateFilterFields.style.display = "block";
      updateDateEndField();
    } else {
      textFilterFields.style.display = "none";
      dateFilterFields.style.display = "none";
    }
  }

  function updateDateEndField() {
    if (dateFilterPatternSelect.value === "between") {
      dateFilterEndField.style.display = "block";
    } else {
      dateFilterEndField.style.display = "none";
    }
  }

  if (filterColumnSelect) {
    filterColumnSelect.addEventListener("change", updateFilterFields);
    dateFilterPatternSelect.addEventListener("change", updateDateEndField);

    // 初期表示時の設定
    updateFilterFields();
  }
});
