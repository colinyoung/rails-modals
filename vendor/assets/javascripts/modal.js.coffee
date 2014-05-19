modals = {}
waits = {}

$ ->  

  $('script[data-path]').each ->
    $(this).modal 'precache'

  $('*[data-open-modal]').on 'click', (e) ->
    e.preventDefault()
    e.stopPropagation()

    $(this).modal 'show'
    
    return false

$.fn.modal = (action) ->
  section = ".bbm-modal__section"
  path = $(this).attr('data-path')
  switch action
    when 'precache'
      req = $.ajax(
        url: path
        success: (html) =>
          # Extracts title from the page title itself.
          title = $.trim html.match(/<title>((?:.|[\r\n])+)<\/title>/)[1]
          # Content is the first form it finds.
          # Add separate pages to forms like <div modal-step>...</div>
          page = $(html)
          html = _.template $(this).html(),
                            title: title
                            content: $(page).find('form').html()
          $(this).html html

        error: (response) =>
          json = JSON.parse response.responseText
          html = _.template $(this).html(), title: "Oops!", content: "<p>#{json.error}</p>"
          $(this).html html

        complete: ->
          # if this request was clicked while this request was loading,
          # display it now that it's loaded.
          if link = waits[path]
            $(link).modal('show').originalText()
      )

      modals[path] = req

    when 'show'
      req = modals[path]
      if req? and req.readyState isnt 4
        $(this).tempText 'One sec...'
        waits[path] = this

      script = $("script[type='text/template'][data-path='#{path}']")

      html = $(script).html()

      modalOptions = if $(html).find('*[modal-step]').length
        # split steps into views
        # -- pending
        {}
      else
        { 
          cancelEl: '.bbm-button'
          template: _.template(html)
        }

      Modal = Backbone.Modal.extend(modalOptions)

      modalView = new Modal()

      $('.modal').html(modalView.render().el)

  this
