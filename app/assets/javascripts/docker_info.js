
function query_dockerimages(server_value, server_id) {
  var url = "/imageurls/" + server_value + ".json"
  response = jQuery.getJSON(url)
  $.getJSON( url, function( data ) {
    var items = [];
    $.each( data, function( key, val ) {
      items.push(val);
    })
    replace_guts(items, server_id)
  });
  };

function replace_guts(options, server_id) {
  //alert(options[0].tag)
  images = server_id.replace("dockerserver_id","image_id");
  var $el = $("#"+images);
  $el.empty();
  $.each(options, function(key,value) {
  $el.append($("<option></option>")
     .attr("value", value.id).text(value.tag));
});
}
