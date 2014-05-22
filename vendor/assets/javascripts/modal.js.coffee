modals = {}
waits = {}

copySelectedOptions = (from, to) ->
  $(from).find('select option:selected').each ->
    selectTag = $(this).parents('select')[0]
    $(to).find("select[name='#{$(selectTag).attr('name')}']").find("option[value='#{$(this).val()}']").attr("selected", "selected")

$ ->  

  $('script[data-path]').each ->
    $(this).modal 'precache'

  $('*[data-open-modal]').on 'click', (e) ->
    e.preventDefault()
    e.stopPropagation()

    $(this).modal 'show'
    
    return false

$.fn.modal = (action, argument) ->
  section = ".bbm-modal__section"
  path = $(this).attr('data-path')
  switch action
    when 'precache'
      req = $.ajax(
        url: path

        success: (html) =>
          return if $("form[data-path='#{path}']").length > 0 # already loaded

          # Extracts title from the page title itself.
          title = $.trim html.match(/<title>((?:.|[\r\n])+)<\/title>/)[1] || 'Modal'
          # Content is the first form it finds.
          # Add separate pages to forms like <div modal-step>...</div>
          page = $(html)
          form = $(page).find('form').clone()
          $('body').append(form)
          $(form).hide().attr('data-path', path).attr('title', title)

          html = _.template $(this).html(),
                            title: title
                            content: form.html()
          $(this).html html

        error: (response) =>
          json = JSON.parse response.responseText
          html = _.template $(this).html(), title: "Oops!", content: "<p>#{json.error}</p>"
          $(this).html html

        complete: (object) =>
          # if this request was clicked while this request was loading,
          # display it now that it's loaded.
          if link = waits[path]
            delete waits[path]
            $(link).modal('show').originalText()
      )

      modals[path] = req

    when 'replaceSubmit'
      submit = $(this).find('input[type=submit]')
      label = $(submit).val()
      bottomBar = $(this).find('.bbm-modal__bottombar')
      $(bottomBar).find('.next').html(label)
                                .show()
                                .addClass('submit')
                                .removeClass('next')
      $(submit).hide()

    when 'setDisplay'
      if argument is 'submitting'
        $(this).find('.bbm-button').css('opacity', 0.5)
        # clone submit to remove click handlers
        submit = $(this).find('.submit').text('Submitting...').css('opacity', 1.0)

    when 'show'
      req = modals[path]
      if req? and req.readyState isnt 4
        $(this).tempText 'One sec...'
        waits[path] = this
        return this

      $(document).trigger 'modal:show'
      $(document).trigger 'modal:page'

      form = $("form[data-path='#{path}']")[0]
      steps = $(form).find('*[data-modal-step]')
      modal = $("script[type='text/template'][data-path='#{path}']")

      modalOptions = if steps.length > 0

        views = {}
        $(steps).each (i, el) ->
          _modal = $(modal).clone()
          $(el).attr('data-modal-step', i)

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
            $(_modal).modal('replaceSubmit')

          if $(_modal).html().indexOf('<%=') > 0
            throw "Template not done"

          views["step#{i}"] = view: _.template($(_modal).html())

        # split steps into views
        {
          cancelEl: '.cancel'
          submitEl: '.submit'
          views: views

          events:
            'click .previous': 'previousStep'
            'click .next': 'nextStep'

          previousStep: (e) ->
            e.preventDefault()
            @previous()
            $(document).trigger 'modal:page'

            # apply all new input changes to each input in modal from existing form
            # We have to poll, unfortunately, until the view is animated in.
            interval = setInterval(=>
              oldStep = $(@el).find('*[data-modal-step]')
              displayingIndex = parseInt $(oldStep).attr('data-modal-step')
              return unless displayingIndex is @currentIndex # keep waiting

              clearInterval(interval) # we made it, clear the interval

              step = $(form).find('*[data-modal-step]')[@currentIndex]
              $(oldStep).replaceWith $(step).clone()
            , 20)

          nextStep: (e, options) ->
            target = if e
              e.preventDefault()
              target = e.target
            else
              this.el
            
            # updates invisible form with changes made in this step.
            section = $(target).parents('.modal').find('.bbm-modal__section')
            step = $(form).find('*[data-modal-step]')[@currentIndex]
            newStep = section.children('*[data-modal-step]')[0]
            newStep = $(newStep).clone() if options? and options.clone
            $(step).replaceWith(newStep)

            # copy selected option tags (they won't persisted selected state when cloned)
            copySelectedOptions(section, newStep)

            @next()

            $(document).trigger 'modal:page'

          beforeSubmit: ->
            return false if @submitting
            @submitting = true # block further submits

            @nextStep(null, clone: true)
            $(this.el).modal('setDisplay', 'submitting')

            form.submit()
            return false # to block disappearance

          beforeCancel: -> !@submitting
        }
      else
        { 
          cancelEl: '.close'
          submitEl: '.submit'
          template: -> $(modal).html()

          beforeSubmit: ->
            return false if @submitting
            @submitting = true # block further submits

            # replace innerHTML of invisible form with fields inside the modal
            $(form).empty()
            section = $(this.el).find('.bbm-modal__section').clone()
            $(form).append(section)

            # copy selected option tags (they won't persisted selected state when cloned)
            copySelectedOptions(this.el, form)

            # display changes when submitting
            $(this.el).modal('setDisplay', 'submitting')

            # submit form
            form.submit()
            return false # to block disappearance

          onRender: ->
            $(this.el).modal('replaceSubmit')

          beforeCancel: -> !@submitting
        }

      Modal = Backbone.Modal.extend(modalOptions)

      modalView = new Modal()

      $('.modal').html(modalView.render().el)
  this
