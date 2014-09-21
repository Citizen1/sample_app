function updateCountdown() {
  // 140 is the max message length
  var remaining = 140 - jQuery('#micropost_content').val().length;
  jQuery('.countdown').text(remaining + ' characters remaining');
}

function micropostChange() {
  $('#micropost_content').change(updateCountdown);
}

function micropostKeyup() {
  $('#micropost_content').keyup(updateCountdown);
}

jQuery(document).on('page:change', function($) {
    updateCountdown();
    micropostChange();
    micropostKeyup();
  });
