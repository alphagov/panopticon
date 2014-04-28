$(document).ready(function() {
  "use strict";

  var $relatedArtefactsWrapper = $(".related-artefacts"),
      $relatedArtefactsTextField = $("#artefact_related_artefact_slugs");

  $relatedArtefactsWrapper
    .children("label")
    .html("Related artefacts")
    .append(' <span class="hint">(drag to reorder)</span>');

  // select2 needs a hidden input to serve our purpose
  var $relatedArtefactsHiddenInput = $('<input type="hidden">')
                                      .attr("name", $relatedArtefactsTextArea.attr("name"))
                                      .attr("value", $relatedArtefactsTextArea.attr("value"));

  $relatedArtefactsTextArea.replaceWith($relatedArtefactsHiddenInput);

  // http://ivaynberg.github.io/select2/select-2.1.html
  $relatedArtefactsHiddenInput.select2({
    width: "75%",
    multiple: true,
    placeholder: "Search for an artefact to relate",
    minimumInputLength: 3,
    initSelection: function(element, callback) {
      callback($relatedArtefactsTextField.data("related-artefacts"));
    },
    formatSelection: function(object) {
      return $("<a>")
               .attr("href", "http://gov.uk/" + object.id)
               .addClass("js-artefact-name")
               .html(object.text)
               .wrap('<p>').parent().html();
    },
    ajax: {
      url: "/artefacts/search_relatable_items.json",
      quietMillis: 100,
      data: function (term, page) {
        return { 'title_substring': term, 'page': page };
      },
      results: function (data, page) {
        var loadMore = (page * 15) < data.total;
        return {results: data.artefacts, more: loadMore};
      }
    },
  });

  $(".js-artefact-name").click(function(e) {
    e.preventDefault();
    window.open($(this).attr("href"));
  });
});
