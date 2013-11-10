class @FeelingCagey

  @boot: ->

    $(window).on('scroll', @hideFooterOnScroll)

    @preloadCage(=>
      @loadInitialPhotos()
      @initializePusher()
    )

  @preloadCage = (callback) ->

    image = new Image()
    image.src = '/img/cage.png'

    $(image).on('load', callback)

  @loadInitialPhotos = ->

    $.ajax(
      url: '/photos.json',
      success: (photos) => $(photos).each((key, value) => @renderPhoto(value, true))
    )

  @initializePusher: ->

    pusher  = new Pusher(PUSHER_KEY)
    channel = pusher.subscribe('cage')
    channel.bind('new_photo', @renderPhoto)

  @hideFooterOnScroll = ->

    scrollTop = $(window).scrollTop()

    $('footer .disclaimer').toggleClass('hidden', scrollTop > 100)

  # Horrible convenience function to render a photo
  @renderPhoto = (photo, append = false) ->

    image = new Image()
    image.src = photo.image_url

    $(image).on('load', ->

      return if append && $('.grid .photo').length >= 25

      gridElement = $('<div />').attr('class', 'pure-u-1-5 photo')

      $('<img />').attr('src', photo.image_url).appendTo(gridElement)
      
      $(photo.faces).each(->

        $('<div class="face"><img src="/img/cage.png"></div>')
          .css('top', "#{@top}%")
          .css('left', "#{@left}%")
          .css('width', "#{@width}%")
          .appendTo(gridElement)

      )

      gridElement[if append then 'appendTo' else 'prependTo']('.grid')

      if $('.grid .photo').length > 25
        target = if append then 'first' else 'last'
        $(".grid .photo:#{target}").remove()

      setTimeout(->

        gridElement.addClass('visible')

      , 50)

    )

@FeelingCagey.boot()