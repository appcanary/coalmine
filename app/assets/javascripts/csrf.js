(function() {
  if ($) {

    $.ajaxSetup( {
      beforeSend: function ( xhr ) {
        var token = $( 'meta[name="csrf-token"]' ).attr( 'content' );
        xhr.setRequestHeader( 'X-CSRF-Token', token );
      }
    });      
  }
})();
