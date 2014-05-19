# Rails::Modals

Turn your links to Rails forms into modals!

## Installation

Add this line to your application's Gemfile:

    gem 'rails-modals'

Then add the following requires to your `application.js` and `application.css` files:

#### application.js (or similar)

    //= require rails-modals

#### application.css (or similar)

    /*= require rails-modals

## Usage

Add the following to the end of your layouts (this example is for ERB):

    <%= modals if modals? %>

Change all your links that you want to link to a modal to the following:

    link_to ... => link_to_modal ...

That's it! Provided your linked-to pages have forms on them, your forms will populate inside a modal.

Incidentally, the title of the modal window is the same as the `<title>` of your linked-to page.

## Optimizing your controllers

The forms are requested over XHR, which must follow all redirects. So if you're in the habit of creating controllers that do this:

```ruby
class MyController < ApplicationController
  def edit
    unless @user.pro?
      flash[:alert] = "You have to be upgraded to edit."
      redirect_to root_path
    end
  end
end
```

Then you want to add a case for `request.xhr?`:

```ruby
class MyController < ApplicationController
  def edit
    unless @user.pro?
      if request.xhr?
        render :status => :forbidden, :json => { error: "You have to be upgraded to edit." }
      else
        flash[:alert] = "You have to be upgraded to edit."
        redirect_to root_path
      end
    end
  end
end
```

The response in this case is expected to be a non-`200` error code, and have an `error` key on a root object as shown. If you follow those simple rules, your error message will display in a modal automatically.


## Steps

Sometimes you want to divide a form into steps, like in a wizard.

This is easy: just do the following in your form:

```html
<form action="..." method="POST">
  <fieldset data-modal-step>
    <label>Fields on page 1 of wizard</label>
  </fieldset>

  <fieldset data-modal-step>
    <label>Fields on page 2 of wizard</label>
  </fieldset>
</form>
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/rails-modals/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
