$(function() {
  $(document).ready(function() {
    var $needIdsSelect = $(".js-artefact-need-ids"),
        maslowNeedsUrl = $("#js-maslow-needs-url").text(),
        needotronNeedsUrl = $("#js-needotron-needs-url").text();

    $needIdsSelect.tagsinput();

    // need the id for easier javascript integration tests
    var tagsInputTextbox = $needIdsSelect.tagsinput("input");
    $(tagsInputTextbox)
      .attr("id", "tagsinput-text-box")
      .attr("size", "6");

    var $needIdTagInputField = $("div.bootstrap-tagsinput input[type=text]");
    $needIdTagInputField.mask("999999");

    $(".js-add-artefact-need-id").live("click", function() {
      $needIdsSelect.tagsinput("add", $needIdTagInputField.val());
      $needIdTagInputField.val("").focus();
    });

    $("#artefact_need_ids_input .tag").live("click", function(e) {
      var needId = $(this).text(),
          sixDigitIntegerMatcherRegex = /^\d{6}$/;

      if(sixDigitIntegerMatcherRegex.test(needId)) {
        window.open(maslowNeedsUrl + needId);
      } else {
        window.open(needotronNeedsUrl + needId);
      }
    });
  });
});
