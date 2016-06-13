$(function() {
  var blankByDefault = ($("#artefact_slug").attr('value') != '');
  var generateSlug = function generateSlug() {
    if(blankByDefault) { return }
    var title = $("#artefact_name").val();
    var slug = title.toLowerCase()
      .replace(/[^\w ]+/g, '')
      .replace(/ +/g, '-')
      .replace(/^-+|-+$/, '')
    $("#artefact_slug").val(slug);
  }
  $("#artefact_name").change(generateSlug)
  $("#artefact_name").bind('keyup', generateSlug)

  $('a[rel=external]').attr('target','_blank');


  $('#add-related').click(function () {
    var new_select = $('.related-artefact-template').clone(true);
    new_select.attr('id', '');
    new_select.removeClass('hidden');
    new_select.removeClass('related-artefact-template');
    new_select.addClass('related-artefact');
    new_select.appendTo('.related-artefact-group');
    return false;
  })

  $('.remove-related').click(function () {
    $(this).parent().remove();
    return false;
  })
});
