Collection = require 'models/base/collection'
ItemModel = require 'models/item'
Topics = require 'config/topics'
yqlFetcher = require 'lib/yqlFetcher'
#PipesID = require 'config/pipes'

module.exports = class ItemsCollection extends Collection
  model: ItemModel

  errorObject =
        error: true

  fetch : (params) ->
    collection = @

    # Fetcher prefs
    # TODO : we must handle l10n & i18n…
    fetcherParams =
      services :
        [
          name: "yahoo"
        ,
          name: "google"
        ]
      category : if params is null or params.section is undefined then '' else params.section
      country : if params is null or params.country is undefined then Topics.defaultCountry else params.country

    # Find google topic in local Topics
    unless params is null or params.section is undefined
      countryTopics = Topics.countries[fetcherParams.country].topics
      currentTopic = _.find countryTopics, (topic) ->
        return (topic.section is fetcherParams.category && topic.gTopic isnt undefined)

      # For specific countries, current google topic sometimes doesn't exist
      unless currentTopic is undefined
        fetcherParams.gTopic = currentTopic.gTopic


    xhrOptions = yqlFetcher.newsURL fetcherParams



    # Make request
    # All failed answers (error code or empty items)
    # are handled directly in site controller
    request = $.ajax(xhrOptions)

    .done (response) =>

      results = response.query.results

      # We'll get a 200 response even if items are null
      if results isnt null
        items = results.item
        # We added a specific key for Google and can test if exists for each item
        for item in items
          # Yahoo now encapsulate image in a content key, but type can be something else than an image
          imageTypePattern = /image/
          if item.content isnt undefined and item.content.type isnt undefined and imageTypePattern.test item.content.type
            item.image = item.content
          # since we don't use pipes anymore, the specific key doesn't exist. We now look for a specific string in guid key
          googleTagPattern = /tag:news.google.com/

          if item.guid isnt undefined and googleTagPattern.test item.guid.content
            item = @parseGoogleNews item

        # Populate the collection
        collection.reset items


  # In Goole news, we must parse HTML descrption field to extract article link, source & image
  parseGoogleNews: (item) ->
    description = item.description
    link = item.link
    sourcePattern = /<font size="-2">([^<]+)/
    imgPattern = /<img.*src=["']([^"']+)["']/
    sourceUrlPattern = /url=(.+)/
    domainPattern = /^((?:http|https):\/\/[^\/]+)/
    item.source = {}

    # Check if we can find a source
    if sourcePattern.test description
      item.source.content = RegExp.$1

    # Check if we can find an image
    if imgPattern.test description
      item.image =
        url : RegExp.$1

    # Extract correct url from Google link
    if sourceUrlPattern.test link
      item.link = RegExp.$1

      # Extract domain from previous parsed link
      if domainPattern.test item.link
        item.source.url = RegExp.$1

        # If we didn't find any source name, we take domain name
        if item.source.content is undefined
          # We remove prefix
          prefixPattern = /(http|https):\/\/(w{3})?/
          item.source.content = item.source.url.replace prefixPattern, ""

    item


# OLD FETCH for pipes
#fetch: (params) ->
#  collection = @
#  pipeURL = "http://pipes.yahoo.com/pipes/pipe.run"
#  pipeID = PipesID[Math.floor (Math.random() * 10)]
#
#  # Check for any params provided (country & section)
#  data =
#    category: (if (params && params.section) is undefined then '' else params.section)
#    country : (if (params && params.country) is undefined then Topics.defaultCountry else params.country
#    _id: pipeID
#    _render: "json"
#
#
#  # Find google topic in local Topics
#  unless (params && params.section) is undefined
#    countryTopics = Topics.countries[data.country].topics
#    currentTopic = _.find countryTopics, (topic) ->
#      return (topic.section is data.category && topic.gTopic isnt undefined)
#
#    # For specific countries, current google topic sometimes doesn't exist
#    unless currentTopic is undefined
#      data.topic = currentTopic.gTopic
#      data.ned = data.country
#
#
#
#  xhrOptions =
#    url : pipeURL
#    type : 'GET'
#    data: data
#
#  request = $.ajax(xhrOptions)
#  .done (response) =>
#
#    items = response.value.items
#
#    # We added a specific key for Google and can test if exists for each item
#    for item in items
#      unless item.isGoogle is undefined
#        item = @parseGoogleNews item
#
#    # Populate the collection
#    collection.reset items
#
#  # Error case
#  # TODO : improve error handling
#  .fail ->
#    errorObject =
#      error: true
#
#    collection.reset errorObject