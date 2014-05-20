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
          form = $(page).find('form').clone()
          $('body').append(form)
          $(form).hide().attr('data-path', path)
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
        return

      form = $("form[data-path='#{path}']")
      modal = $("script[type='text/template'][data-path='#{path}']")

      steps = $(form).find('*[data-modal-step]')

      modalOptions = if steps.length > 0
        views = {}
        $(steps).each (i, el) ->
          _modal = $(modal).clone()

          # replace top bar buttons with relevant buttons
          topBar = $(_modal).find('.bbm-modal__topbar')
          $(topBar).find('.cancel').show()

          # replace section with this step
          section = $(_modal).find('.bbm-modal__section')
          $(section).html($(el).clone())

          # replace buttons with relevant buttons
          bottomBar = $(_modal).find('.bbm-modal__bottombar')
          $(bottomBar).find('.close').hide()
          
          $(bottomBar).find('.next').show()
          $(bottomBar).find('.previous').show() unless i is 0

          if i >= (steps.length - 1)
            submit = $(_modal).find('input[type=submit]')
            label = $(submit).val()
            $(bottomBar).find('.next').html(label).show().addClass('submit')
            $(submit).hide()

          views["step#{i}"] = { view: _.template($(_modal).html()) }

        # split steps into views
        {
          cancelEl: '.cancel'
          submitEl: '.done'
          views: views

          events:
            'click .previous': 'previousStep'
            'click .next': 'nextStep'

          previousStep: (e) ->
            e.preventDefault();
            @previous()

          nextStep: (e) ->
            e.preventDefault();
            @next()
        }
      else
        { 
          cancelEl: '.close'
          template: _.template($(modal).html())
        }

      Modal = Backbone.Modal.extend(modalOptions)

      modalView = new Modal()

      $('.modal').html(modalView.render().el)

  this
