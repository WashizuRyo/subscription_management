import jQuery from "jquery";
window.$ = jQuery;

function initializeFilters() {
  const $document = $(document);
  const $filterColumnSelect = $("select[name='q[filter_column]']");
  const $rangePatternContainer = $("#range_filter_pattern_container");
  const $rangePatternSelect = $("select[name='q[date_filter_pattern]']");
  const $rangeFields = $("#range_filter_fields");
  const $rangeEndField = $("#range_filter_end_field");
  const $rangeStartInput = $("#range_filter_start_input");
  const $rangeEndInput = $("#range_filter_end_input");
  const $rangeStartLabel = $("#range_filter_start_label");
  const $rangeEndLabel = $("#range_filter_end_label");
  const $textFilterPattern = $("#text_filter_pattern");
  const $textFilterFields = $("#text_filter_fields");
  const $textFilterInput = $textFilterFields.find("input[name='q[text_filter_value]']");
  const defaultStartLabel = $rangeStartLabel.text();
  const defaultEndLabel = $rangeEndLabel.text();

  $document.off("change", "select[name='q[filter_column]']");
  $document.off("change", "select[name='q[date_filter_pattern]']");
  $document.off("click", "#add_filter_button");
  $document.off("click", "#open_filter_box");
  $document.off("click", "#open_sort_box");
  $document.off("click", "#add_sort_button");

  function disableRangeInputs() {
    $rangeStartInput.prop("disabled", true);
    $rangeEndInput.prop("disabled", true);
  }

  function enableRangeInputs() {
    $rangeStartInput.prop("disabled", false);
    if ($rangeEndField.is(":visible")) {
      $rangeEndInput.prop("disabled", false);
    }
  }

  function resetRangeInputAttributes() {
    $rangeStartInput.removeAttr("type").attr("type", "text");
    $rangeEndInput.removeAttr("type").attr("type", "text");
    [ $rangeStartInput, $rangeEndInput ].forEach(($input) => {
      $input.removeAttr("step");
      $input.removeAttr("min");
      $input.removeAttr("max");
    });
    $rangeStartLabel.text(defaultStartLabel);
    $rangeEndLabel.text(defaultEndLabel);
  }

  function hideTextFields() {
    $textFilterPattern.hide();
    $textFilterFields.hide();
    $textFilterInput.prop("disabled", true);
  }

  function showTextFields() {
    $textFilterPattern.show();
    $textFilterFields.show();
    $textFilterInput.prop("disabled", false);
  }

  function hideRangeFields() {
    $rangePatternContainer.hide();
    $rangeFields.hide();
    $rangeEndField.hide();
    disableRangeInputs();
  }

  function updateRangeFieldVisibility(pattern) {
    if (pattern === "between") {
      $rangeEndField.show();
      $rangeEndInput.prop("disabled", false);
    } else {
      $rangeEndField.hide();
      $rangeEndInput.prop("disabled", true);
    }
  }

  function readSelectedConfig() {
    const $selectedOption = $filterColumnSelect.find("option:selected");
    if ($selectedOption.length === 0) {
      return null;
    }

    const type = $selectedOption.data("filterType");
    if (!type) {
      return null;
    }

    return {
      type,
      step: $selectedOption.data("rangeStep"),
      min: $selectedOption.data("rangeMin"),
      max: $selectedOption.data("rangeMax"),
      startLabel: $selectedOption.data("rangeStartLabel"),
      endLabel: $selectedOption.data("rangeEndLabel")
    };
  }

  function configureRangeFields(config) {
    hideTextFields();
    $rangePatternContainer.show();
    $rangeFields.show();
    $rangePatternSelect.prop("disabled", false);

    resetRangeInputAttributes();

    const type = config.type;
    if (type === "date") {
      $rangeStartInput.attr("type", "date");
      $rangeEndInput.attr("type", "date");
    } else if (type === "number") {
      $rangeStartInput.attr("type", "number");
      $rangeEndInput.attr("type", "number");
      if (config.step) {
        $rangeStartInput.attr("step", config.step);
        $rangeEndInput.attr("step", config.step);
      }
      if (config.min) {
        $rangeStartInput.attr("min", config.min);
        $rangeEndInput.attr("min", config.min);
      }
      if (config.max) {
        $rangeStartInput.attr("max", config.max);
        $rangeEndInput.attr("max", config.max);
      }
    }

    if (config.start_label) {
      $rangeStartLabel.text(config.start_label);
    }
    if (config.end_label) {
      $rangeEndLabel.text(config.end_label);
    }

    updateRangeFieldVisibility($rangePatternSelect.val());
    enableRangeInputs();
  }

  function configureTextFields() {
    showTextFields();
    hideRangeFields();
    resetRangeInputAttributes();
    $rangePatternSelect.prop("disabled", true);
  }

  function resetFilters() {
    hideTextFields();
    hideRangeFields();
    resetRangeInputAttributes();
    $rangePatternSelect.prop("disabled", true);
  }

  $document.on("change", "select[name='q[filter_column]']", function() {
    const selectedColumn = $(this).val();
    const config = readSelectedConfig();

    if (!selectedColumn || !config) {
      resetFilters();
      return;
    }

    if (config.type === "text") {
      configureTextFields();
    } else {
      configureRangeFields({
        type: config.type,
        step: config.step,
        min: config.min,
        max: config.max,
        start_label: config.startLabel,
        end_label: config.endLabel
      });
    }
  });

  $document.on("change", "select[name='q[date_filter_pattern]']", function() {
    const selectedPattern = $(this).val();
    updateRangeFieldVisibility(selectedPattern);
    enableRangeInputs();
  });

  $document.on("click", "#add_filter_button", function() {
    $("#filter_box").hide();
  });

  $document.on("click", "#open_filter_box", function() {
    $("#filter_box").toggle();
  });

  $document.on("click", "#open_sort_box", function() {
    $("#sort_box").toggle();
  });

  $document.on("click", "#add_sort_button", function() {
    $("#sort_box").hide();
  });

  if ($filterColumnSelect.length > 0) {
    $filterColumnSelect.trigger("change");
  }
}

document.addEventListener("turbo:load", initializeFilters);
document.addEventListener("turbo:render", initializeFilters);
document.addEventListener("turbo:frame-render", initializeFilters);
document.addEventListener("turbo:submit-end", initializeFilters);

$(document).ready(initializeFilters);
