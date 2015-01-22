// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .
//= require jquery_nested_form
//= require twitter/bootstrap
//
function remove_dockerserver(link) {
// console.log(link)
//  console.log($(link).parent().parent())
  $(link).parent().parent(".dockerserver").hide();
  $(link).parentNode.style.display = "none"
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).parent().before(content.replace(regexp, new_id));
}

function remove_unnecessary_fields(element, value) {
  var heroku_fields = document.getElementsByClassName('heroku');
  var openshift_fields = document.getElementsByClassName('openshift');
  if (value == 1) 
    // openshift
  {
    console.log(heroku_fields)
    for (var i = 0; i < heroku_fields.length; i++) {
      heroku_fields[i].style.display='none';
    }
    for (var i = 0; i < openshift_fields.length; i++) {
      openshift_fields[i].style.display='inline';
    }

  }
  else {
    for (var i = 0; i < heroku_fields.length; i++) {
      heroku_fields[i].style.display='inline';
    }
    for (var i = 0; i < openshift_fields.length; i++) {
      openshift_fields[i].style.display='none';
    }
 
  }
}


$(".field").mouseover(function() {
      $(this).children(".description").show();
}).mouseout(function() {
      $(this).children(".description").hide();
});

