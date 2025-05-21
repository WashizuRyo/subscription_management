import jQuery from "jquery";
window.$ = jQuery;


// フィルターの初期化と設定を行う関数
function initializeFilters() {
  // 既存イベントを解除（重複防止）
  $(document).off("change", "select[name='q[filter_column]']");
  $(document).off("change", "select[name='q[date_filter_pattern]']");
  $(document).off("click", "#add_filter_button");
  $(document).off("click", "#open_filter_box");
  $(document).off("click", "#open_sort_box");
  $(document).off("click", "#add_sort_button");

  // イベント委譲でバインド
  $(document).on("change", "select[name='q[filter_column]']", function() {
    const selectedColumn = $(this).val();
    if (selectedColumn === "name" || selectedColumn === "plan_name") {
      $("#text_filter_pattern").show();
      $("#text_filter_value_field").show();
      $("#date_filter_fields").hide();
    } else if (
        selectedColumn === "price" ||
        selectedColumn === "start_date" ||
        selectedColumn === "end_date" ||
        selectedColumn === "billing_date"
    ) {
      $("#text_filter_pattern").hide();
      $("#text_filter_value_field").hide();
      $("#date_filter_fields").show();
      $("#q_text_filter_patter").show();
    } else {
      $("#text_filter_fields").hide();
      $("#date_filter_fields").hide();
    }
  });

  $(document).on("change", "select[name='q[date_filter_pattern]']", function() {
    const selectedPattern = $(this).val();
    if (selectedPattern === "between") {
      $("#date_filter_end_field").show();
    } else {
      $("#date_filter_end_field").hide();
    }
  });

  $(document).on("click", "#add_filter_button", function() {
    $("#filter_box").hide();
  });

  $(document).on("click", "#open_filter_box", function() {
    $("#filter_box").toggle();
  });

  $(document).on("click", "#open_sort_box", function() {
    $("#sort_box").toggle();
  });

  $(document).on("click", "#add_sort_button", function() {
    $("#sort_box").hide();
  });
}

// Turboイベントで初期化
document.addEventListener("turbo:load", initializeFilters);
document.addEventListener("turbo:render", initializeFilters);
document.addEventListener("turbo:frame-render", initializeFilters);
document.addEventListener("turbo:submit-end", initializeFilters);

// ページ初回ロード時も初期化
$(document).ready(initializeFilters);