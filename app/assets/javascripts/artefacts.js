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

  $('.flash-notice').delay(4000).slideUp(300).
    one('click', function () { $(this).slideUp(300); });

  // add sections
  $('#add-section').click(function () {
    $('.remove-section').show();
    var new_select = $('.artefact-section').first().clone(true);
    new_select.find('select option:selected').removeAttr('selected');
    new_select.insertBefore(this);
    return false;
  })

  $('.remove-section').click(function () {
    if ($('.artefact-section').size() >= 2) {
      $(this).parent().remove();
      if ($('.artefact-section').size() == 1) {
        $('.remove-section').hide();
      }
    }
    return false;
  })


  $('#add-related').click(function () {
    $('.remove-related').show();
    var new_select = $('.related-artefact').first().clone(true);
    new_select.find('select option:selected').removeAttr('selected');
    new_select.insertAfter('.related-artefact:last');
    return false;
  })

  $('.remove-related').click(function () {
    if ($('.related-artefact').size() >= 2) {
      $(this).parent().remove();
      if ($('.related-artefact').size() == 1) {
        $('.remove-related').hide();
      }
    }
    return false;
  })
});
