// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery_ujs
//= require rails-ujs
//= require jquery
//= require materialize-sprockets
//= require vue
//= require best_in_place
//= require_tree .
//= require materialize-form

// @import "materialize";
// @import "https://fonts.googleapis.com/icon?family=Material+Icons";

// Sticky footer js
// Thanks to Charles Smith for this -- http://foundation.zurb.com/forum/posts/629-sticky-footer
$(window).bind("load", function () {
  var footer = $("#footer");
  var pos = footer.position();
  var height = $(window).height();
  height = height - pos.top;
  height = height - footer.height();
  if (height > 0) {
      footer.css({
          'margin-top': height + 'px'
      });
  }
});

// Flash fade
$(function() {
   $('.alert-box').fadeIn('normal', function() {
      $(this).delay(3500).fadeOut();
   });
});

// Best in place functionality
$(document).ready(function() {
  window.materializeForm.init()
  jQuery(".best_in_place").best_in_place();
  $('.slider').slider({
    indicators: false
  });
  $('.tabs').tabs({
    swipeable: true
  });
  $('.timepicker').timepicker();
  $('.datepicker').datepicker();
});

// Search submit on enter
$(document).ready(function() {
  function submitForm() {
    document.getElementById("search").submit();
  }
  document.onkeydown = function () {
    if (window.event.keyCode == '13') {
        submitForm();
    }
  }
});

$(document).ready(function() {

    $('#finished_shifts tr').click(function() {
        var href = $(this).find("a").attr("href");
        if(href) {
          window.location = href;
        }
    });

});
