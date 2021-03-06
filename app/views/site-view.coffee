View = require 'views/base/view'
template = require 'views/templates/site'

# Site view is a top-level view which is bound to body.
module.exports = class SiteView extends View
  autoRender: true
  container: 'body'
  id: 'site-container'
  regions:
    items: '#page-container'
    header: '#header-container'
    nav: '#nav-container'
    preloader: '#preloader-container'
    errorNotifier: '#error-container'
  template: template


  initialize: (options) ->

    @delegate "mouseenter", "header", @toggleHeader
    @delegate "mouseenter", "#page-container", @toggleHeader


  toggleHeader: (e) ->
    target = $(e.currentTarget)
    header = @$el.find("#wrapper").find("header")
    if target.is("#header-container")
      header.addClass "showMe"
    else
      header.removeClass "showMe"
