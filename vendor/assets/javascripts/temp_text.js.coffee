# Temporarily replaces the text of a link or button, storing the original text.
$.fn.tempText = (text) ->
  tempText = $(this).attr('data-temp-text')
  return if tempText? and tempText.length > 0
  original = $(this).text()
  if $.trim(original) == $(this).find('i.fa span').text() # ignore text labels in <i> tags
    return $(this).attr('data-temp-html', $(this).html()).html('<i class="fa fa-spin fa-spinner"></i>')
  return if original.length == 0 # return if there's no text
  $(this).text(text)
         .attr('data-temp-text', original)

$.fn.originalText = ->
  if original = $(this).attr('data-temp-html')
    $(this).removeAttr('data-temp-html').html(original)
  else
    original = $(this).attr('data-temp-text')
    $(this).removeAttr('data-temp-text')
           .text(original)
