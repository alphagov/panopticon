$(document).ready(function() {
  var $needIdsFieldWrapper = $("#artefact_need_ids_input"),
      $needIdsField = $(".js-artefact-need-ids"),
      maslowNeedsUrl = $needIdsField.data("maslow-needs-url"),
      needotronNeedsUrl = $needIdsField.data("needotron-needs-url");

  var existingNeedIds = $needIdsField.attr("value") !== undefined ?
                        $needIdsField.attr("value").split(",") :
                        [];

  $needIdsField.tagsManager({
    prefilled: existingNeedIds,
    hiddenTagListName: $needIdsField.attr("name"),
    delimiters: [],
  });

  $needIdsField
    .val("")
    .attr("name", "")
    .attr("style", "width: 60px")
    .mask("999999");

  $addNeedIdLink = $("<a>")
                    .text("Add Maslow Need ID")
                    .attr("href", "#")
                    .attr("id", "add-artefact-need-id")
                    .addClass("btn btn-primary btn-sm js-add-artefact-need-id")
                    .click(function(e) {
                      e.preventDefault();
                      $needIdsField.tagsManager("pushTag", $needIdsField.val());
                      $needIdsField.val("").focus();
                    })
                    .insertAfter($needIdsField);

  $needIdsFieldWrapper.on("click", ".tm-tag span", function(e) {
    e.preventDefault();

    var needId = $(this).text(),
        sixDigitIntegerMatcherRegex = /^\d{6}$/;

    if(sixDigitIntegerMatcherRegex.test(needId)) {
      window.open(maslowNeedsUrl + needId);
    } else {
      window.open(needotronNeedsUrl + needId);
    }
  });

  $needIdsFieldWrapper.find("label span.non-js-hint").hide();
});
