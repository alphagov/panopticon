$(function() {
  $('#add-curated-artefact').click(function () {
    var new_select = $('.curated-artefact-template').clone(true);
    new_select.removeClass('hidden');
    new_select.removeClass('curated-artefact-template');
    new_select.addClass('curated-artefact');
    new_select.appendTo('.curated-artefact-group');
    return false;
  })

  $('.remove-curated-artefact').click(function () {
    $(this).parent().remove();
    return false;
  })
});
