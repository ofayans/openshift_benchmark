# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#The $ -> syntax is coffee script for $(function() {});
#http://stackoverflow.com/a/10188403
ready = ->
  $('[data-toggle="popover"]').popover({
    trigger: 'hover',
    'placement': 'left'
    'html': true
  });
$(document).ready(ready)
$(document).on('page:load', ready)
