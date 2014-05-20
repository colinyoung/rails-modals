# Temporarily replaces the text of a link or button, storing the original text.
$.fn.tempText = (text) ->
  tempText = $(this).attr('data-temp-text')
  return if tempText? and tempText.length > 0
  original = $(this).text()
  $(this).text(text)
         .attr('data-temp-text', original)

$.fn.originalText = ->
  original = $(this).attr('data-temp-text')
  $(this).removeAttr('data-temp-text')
         .text(original)
