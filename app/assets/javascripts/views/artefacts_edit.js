$(function() {
  $(document).ready(function() {
    var needIdsSelect = $(".js-artefact-need-ids");
    needIdsSelect.tagsinput();

    var needIdTagInputField = $("div.bootstrap-tagsinput input[type=text]")
    needIdTagInputField.mask("999999");
    $(".js-add-artefact-need-id").live("click", function() {
      needIdsSelect.tagsinput("add", needIdTagInputField.val());
      needIdTagInputField.val("").focus();
    });
  });
});
