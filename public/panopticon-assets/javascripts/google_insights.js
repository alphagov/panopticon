$(document).ready(function() {
  var label = $('label[for=artefact_name]')
  if(label.size() == 0) { return }

  var insights = $('<a class="insights"><img src="/assets/icon-insights.gif" title="launch Google Insights for this title in a pop-up window" /></a>')

  insights.click(function () {
    var search_term = $('#artefact_name').val()
    $('body').append('<iframe id="popup" src="/google_insight?search_term='+encodeURIComponent(search_term)+'" height="410" scrolling="NO" width="330"></iframe>')
  })

  insights.appendTo(label)
})
