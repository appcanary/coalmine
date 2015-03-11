// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require vendor/velocity
//= require vendor/velocity.ui
//= require vendor/validator
//= require vendor/jquery.timeago
//= require_tree .

jQuery(document).ready(function() {
  jQuery(".timestamp").timeago();

  if($(".app-sidepanel").length > 0) {
    $(".app-sidepanel").velocity("transition.slideLeftBigIn", 400, function() {
      $(".timeline-box, .event-box").velocity("transition.slideDownIn", { stagger: 250 });
    }).delay(250).velocity({'z-index': 1});

  }
  else {
    $(".timeline-box, .event-box").velocity("transition.slideDownIn", { stagger: 250 }).delay(100);
  }
});
