Handlebars.registerHelper 'fromNow', (time) -> moment(time).fromNow()

Template.general_info_block.weather_data = () -> Session.get "weather_data"
Template.temperature_block.weather_data = () -> Session.get "weather_data"
Template.location_block.weather_data = () -> Session.get "weather_data"
Template.clothes_block.images = () ->
  result = []

  if codes = Session.get "weather_codes"
    for code in codes
      result.push img_url: "#{code.weather}.jpg"

  if data = Session.get "weather_data"
    if parseFloat(data.ob.snowDepthIN)
      result.push img_url: "snow-boots.jpg"
    if parseFloat(data.ob.feelslikeF) < 32
      result.push img_url: "parka.jpg"

  result
@updateData = () ->
  if navigator.geolocation then navigator.geolocation.getCurrentPosition (position) ->
    $.ajax
      url: "https://api.aerisapi.com/observations/?p=#{position.coords.latitude},#{position.coords.longitude}&limit=1&client_id=Ur1A6uXUICsx2sAMVMVFx&client_secret=h3DCLShjSHK76FYQ3wI1sMWXVck5Z6SqfzIZQkFM"
      dataType: 'jsonp'
      success: (data) ->
        if not data.success
          console.log data.error.description
          return false
        Session.set "weather_data", data.response
        weather_codes = []
        for code in data.response.ob.weatherCoded.split(',')
          data = code.split(':')
          weather_codes.push {
            coverage:  data[0]
            intensity: data[1]
            weather:   data[2]
          }

        Session.set "weather_codes", weather_codes


Meteor.startup () ->
  updateData()
  Meteor.setInterval updateData, 5000