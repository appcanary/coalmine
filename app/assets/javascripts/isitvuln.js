//= require jquery
//= require isitvuln/dropzone

Dropzone.autoDiscover = false;

$(document).ready(function() {
  if ($("#preferred_platform").length > 0) {
    $("#preferred_platform").on("submit", function(e) {
      e.preventDefault();
      $.post($(this).attr("action"), {
        'pre_user[preferred_platform]': $(this).children('#pre_user_preferred_platform').val(),
        'pre_user[email]': $(this).children('#pre_user_email').val(),
        'pre_user[from_isitvuln]': $(this).children('#pre_user_from_isitvuln').val(),
        'authenticity_token': $(this).children('#authenticity_token').val()
      }).done(function(data) {
        $(".flash-notice").html("<p>Thanks! We'll be in touch soon.</p>").show();
      });
    });
  }

  if ($("#drop").length > 0) {
    var myDropzone = new Dropzone("form#drop", {
      clickable: "#dragbox",
      autoProcessQueue: true,
      createImageThumbnails: false,
      previewTemplate : '<div style="display:none"></div>',
      init: function() {
        this.on("addedfile", function(file) {
          $("#dragmessage").hide();
          $("#spinner").show();
        })
        this.on("success", function(file, response) {
          if (typeof analytics != "undefined") {
            analytics.track('IsItVulnerable Upload')
          }
          window.location = "/results/" + response.id
        });
        this.on("error", function(file, response) {
          $("#dragmessage").show();
          $("#spinner").hide();
          $(".flash-error").html("<p>" + response.error + "</p>").show();
        });
      },
    });
  }
});
