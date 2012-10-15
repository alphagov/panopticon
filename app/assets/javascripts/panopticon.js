$(document).ready(function() {
  $(".chzn-select").chosen();
  if ($('.artefact-section').size() == 1) {
    $('.remove-section').hide();
  }

  $('#artefact-list').tablesorter();
});