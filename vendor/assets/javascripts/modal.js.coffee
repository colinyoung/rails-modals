BBM_TEMPLATE = '
<div class="bbm-modal__topbar">
  <h3 class="bbm-modal__title"><%= title %></h3>
  <a href="javascript:;" class="bbm-button cancel" style="display: none">&times; Cancel</a>
</div>
<div class="bbm-modal__section">
  <%= content %>
</div>
<div class="bbm-modal__bottombar">
  <a href="javascript:;" class="bbm-button close">Close</a>
  <a href="javascript:;" class="bbm-button previous" style="display: none">Previous</a>          
  <a href="javascript:;" class="bbm-button next" style="display: none">Next</a>
</div>'

modals = {}
waits = {}
validationsUnsupported = typeof $('<input>')[0].checkValidity isnt "function"

_validate = (item) ->
  section = $(item.el).find('.bbm-modal__section')
  
  $(item.el).find('p.error').remove()

  allValid = _.every section.find('input'), (i) -> i.validity.valid

  unless validationsUnsupported or allValid
    section.find('span.error').remove()
    section.find('input').each ->
      if !this.validity.valid
        message = this.title || this.validationMessage
        name = $(this).attr('name')
        field = $(section).find("input[name='#{name}']")
        errorSpan = $("<p class='error'>#{message}</p>")
        $(field).addClass('invalid').after errorSpan
        $(['keyup', 'change', 'blur']).each (i, event) ->
          $(field).on event, ->
            $(this).siblings(".error").remove()

    return false

  true

# generic function to copy the selected state of some <select> html, which doesn't persist in a jquery clone
copySelectedOptions = (from, to) ->
  $(from).find('select option:selected').each ->
    selectTag = $(this).parents('select')[0]
    $(to).find("select[name='#{$(selectTag).attr('name')}']").find("option[value='#{$(this).val()}']").attr("selected", "selected")

replaceFileFields = (from, to) ->
  $(from).find("input[type=file]").each (i, inputFrom) ->
    target = $(to).find("input[type=file][name='#{$(inputFrom).attr('name')}']")
    target.replaceWith(inputFrom)

# Calls a function when the modal is ready for display (or another page is displayed)
onDisplay = (func) ->
  addHTML = setInterval(
    =>
      section = $('.modal .bbm-modal__section')
      return unless $(section).innerHeight() > 0 and $(section).is(":visible")
      func.call(this)
      clearInterval(addHTML)
    , 20
  )

$ ->  

  $('script[data-path]').each ->
    $(this).modal 'precache' if $(this).attr("data-precache")

  $(document.body).on 'click', '*[data-open-modal]', (e) ->
    e.preventDefault()
    e.stopPropagation()

    $(this).modal 'show'
    
    return false

  if (hash = window.location.hash).length > 0
    hash = hash.replace(/^#/, '')
    link = $("a[data-open-modal][href='#{hash}']")
    if link[0]
      $(link[0]).modal('show')

$.fn.modal = (action, argument, message) ->
  section = ".bbm-modal__section"
  path = $(this).attr('data-path')
  switch action
    when 'precache'
      req = $.ajax(
        url: path

        success: (html) =>
          return if $("form[data-path='#{path}']").length > 0 # already loaded

          # Extracts title from the page title itself.
          title = html.match(/<title>((?:.|[\r\n])+)<\/title>/)[1] || 'Modal'
          title = title.replace(/(?:\||::|>).*$/, '') # replace common title separators like "Contact Us | My Site Name"
          title = $.trim title
          # Content is the first form it finds.
          # Add separate pages to forms like <div modal-step>...</div>
          page = $(html)
          form = $(page).find('form').clone()
          $(form).attr('data-remote', true) if $(this).attr('data-remote-modal') is "true"
          $('body').append(form)
          $(form).hide().attr('data-path', path).attr('title', title)

          html = _.template BBM_TEMPLATE,
                            title: title
                            content: form.html()
          $(this).html html

        error: (response) =>
          try
            json = JSON.parse response.responseText
          catch e
            json = { error: "We're sorry, there was an error." }
          html = _.template BBM_TEMPLATE, title: "Oops!", content: "<p>#{json.error}</p>"
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
                                .css('display', '')
                                .addClass('submit')
                                .removeClass('next')
      $(submit).hide()

    when 'setDisplay'
      if argument is 'submitting'
        $(this).find('.bbm-button').css('opacity', 0.5)
        # clone submit to remove click handlers
        submit = $(this).find('.submit').addClass('disabled').tempText('Submitting...')

    when 'error'
      $('.modal').addClass('modal-error')
      $('.modal').find('.submit').originalText()

      # go to the step number sent as argument
      modalView = this[0]
      viewObj = modalView.views["step#{argument}"]
      modalView.triggerView(data: viewObj)

      # add HTML
      onDisplay(-> $('.bbm-modal__section').prepend(message))

    when 'show'
      req = modals[path]
      unless req
        $("script[data-path='#{path}']").modal('precache')
        req = modals[path]
        
      if req? and req.readyState < 4
        $(this).tempText 'One sec...' if $(this).data('displayLoading')
        waits[path] = this
        return this

      $(document).trigger 'modal:show'
      onDisplay(-> $(document).trigger('modal:page'))

      form = $("form[data-path='#{path}']")[0] # only take the first form matching the path

      if form?
        form = $([form]) # wrap form again so that we can call .submit() for jquery-ujs and other jquery event listeners on 'submit'

        steps = $(form).find('*[data-modal-step]')
      
      modal = $("script[type='text/template'][data-path='#{path}']")

      modalOptions = if steps? and steps.length > 0

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
            
            onDisplay(-> $(document).trigger('modal:page'))

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
            replaceFileFields(section, newStep)

            @next()

            onDisplay(-> $(document).trigger('modal:page'))

          beforeSubmit: ->
            return false if @submitting or !_validate(this)

            @submitting = true # block further submits

            @nextStep(null, clone: true)
            $(this.el).modal('setDisplay', 'submitting')

            form.submit() if $(this.el).find('.submit')[0]
            @submitting = false
            return false # to block disappearance

          beforeCancel: -> !@submitting
        }
      else
        { 
          cancelEl: '.close'
          submitEl: '.submit'
          template: -> $(modal).html()

          beforeSubmit: ->
            return false if @submitting or !_validate(this)

            @submitting = true # block further submits

            # replace innerHTML of invisible form with fields inside the modal
            $(form).empty()
            section = $(this.el).find('.bbm-modal__section').clone()
            $(form).append(section)

            # copy selected option tags (they won't persisted selected state when cloned)
            copySelectedOptions(this.el, form)
            replaceFileFields(this.el, form)

            # display changes when submitting
            $(this.el).modal('setDisplay', 'submitting')

            form.submit()

            return false # to block disappearance

          onRender: ->
            if form
              $(this.el).modal('replaceSubmit')
            else
              $(this.el).find(".submit").hide()
              $(this.el).find(".close").addClass('alone')

          beforeCancel: -> !@submitting
        }

      Modal = Backbone.Modal.extend(modalOptions)

      modalView = new Modal()

      # bind submit events because this is a remote form
      if form? and $(form).attr('data-remote')

        $(form).bind 'ajax:complete', ->
          $('.bbm-modal').empty() # so that pages are re-rendered

        $(form).bind 'ajax:success', (jqueryEvent, responseText, textStatus, xhr) =>
          if responseText.match(/[0-9]+ errors? prohibited this [a-z ]+ from being saved/)
            errors = $(responseText).find("#error_explanation")
            return $(modalView).modal('error', 0, errors)

          successPath = if responseText.indexOf['{'] is 0
            JSON.parse(responseText)['success_path']
          else
            xhr.getResponseHeader('X-Success-Path')

          if successPath
            window.location.href = successPath
          else
            window.location.reload()

        $(form).bind 'ajax:error', (xhr, status, error) ->
          responseText = xhr.responseText
          errors = $('<div id="error_explanation"><p>There was an error.</p></div>')
          if responseText.indexOf['{'] is 0
            errorObj = JSON.parse(responseText)['error']
            ul = $('<ul>')
            if _.isArray(errorObj)
              $(errorObj).each -> $(ul).append("<li>#{this}</li>")
            else
              $(ul).append("<li>#{errorObj}</li>")
            $(errors).append(ul)
          
          $(modalView).modal('error', 0, errors.html())

      $('.modal').html(modalView.render().el)

      title = $('.modal').find('.bbm-modal__title').text()
      $('.modal').attr('data-path', path)
                 .attr('data-title', title)
  this
