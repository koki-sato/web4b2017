var record = '';

$(function() {
  $('.janken-btn').on('click', function(){
    var hand = $(this).text();
    var check_digest = $.md5(record + ':' + hand);
    var data = {
        hand: hand,
        record: record,
        check_digest: check_digest
    };
    $('.alert').removeClass(function(index, className) {
      return (className.match(/\balert-\S+/g) || []).join(' ');
    });
    $('.alert').html('');

    $.ajax({
      type: 'post',
      url: '/api/v1/game/judge',
      data: JSON.stringify(data),
      contentType: 'application/json',
      dataType: 'json',
      success: function(data) {
        record = data['record'];
        if (data['result'] == 1) {
          $('.alert').addClass('alert-success alert-game');
          $('.alert').html(data['message']);
          $('.result').append('<li>win</li>');
        } else if (data['result'] == 0) {
          $('.alert').addClass('alert-warning alert-game');
          $('.alert').html(data['message']);
          $('.result').append('<li>draw</li>');
        } else if (data['result'] == -1) {
          $('.alert').addClass('alert-danger alert-game');
          $('.alert').html(data['message']);
          $('.result').append('<li>lose</li>');
        }
      },
      error : function() {
        $('.alert').addClass('alert-danger alert-game');
        $('.alert').html("Server Error. Pleasy try again later.");
        console.log("Server Error. Pleasy try again later.");
      }
    });
  });
});
