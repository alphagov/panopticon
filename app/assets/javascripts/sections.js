$(function() {

	$('#add-module').click(function () {
	  var new_select = $('.module-template').clone(true);
	  new_select.removeClass('hidden');
	  new_select.removeClass('module-template');
	  new_select.addClass('module');
	  new_select.appendTo('.modules-group');
	  return false;
	})
	
	$('.remove-module').click(function () {
    $(this).parent().remove();
    return false;
  })

	$('.modules-group').sortable();

});