//= require jquery

$(document).ready(function() {
  $("#file").on("change", function(e) {
    $("form").submit();
  });
})

// 
// Dropzone.autoDiscover = false;
// 
// $(document).ready(function() {
//   var myDropzone = new Dropzone("form#drop", { 
//     clickable: "#dragbox",
//     autoProcessQueue: false,
//     createImageThumbnails: false,
//     previewTemplate : '<div style="display:none"></div>',
//     init: function() {
//       var dz = this;
// 
//     }
//   });
// });
