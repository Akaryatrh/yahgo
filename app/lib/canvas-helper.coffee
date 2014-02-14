
canvasHelper =

  # Takes a canvas element, and fill it with image data
  resizeCanvasToContainer : (canvasElem, data) ->

    containerWidth  = canvasElem.parent().width()
    containerHeight  = canvasElem.parent().height()
    if data is undefined
      # No data provided, we have to extract data from canvas
      data = canvasElem[0].toDataURL()

    ctx = canvasElem[0].getContext '2d'
    img = new Image
    img.src = data
    img.onload = ->
      # redraw
      ctx.drawImage img, 0, 0, containerWidth, containerHeight


  windowEvents :

    lastScrollTop: 0
    initListeners : ->
      el = window
      el.addEventListener "scroll", =>
        @checkScrollPos @
      ,false
      #el.addEventListener "resize", @resizeAllCanvas, false


    checkScrollPos : (_this) ->
      header = $("header")
      scrollTop = $(window).scrollTop()

      if scrollTop >= _this.lastScrollTop
        header.removeClass "showMe"
      else
        header.addClass "showMe"



      # Maybe some enhancements needed… The transition when scrollTop is close to header height could be smoothier.
      if scrollTop > header.height()
        header.addClass "scrolled"
      else
        header.removeClass "scrolled"

      _this.lastScrollTop = scrollTop

    resizeAllCanvas : ->
      $("#page-container .items .item .imgContainer canvas").each ->
        canvasHelper.resizeCanvasToContainer $(this)

# Prevent creating new properties and stuff.
Object.seal? canvasHelper
module.exports = canvasHelper
