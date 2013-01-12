(function($){
  var ID_ACTIONS = {
    'open_hulu': function(){ $.post('/open/hulu_desktop'); },
    'close_hulu': function(){ $.post('/close/hulu_desktop'); },
    'open_plex': function(){ $.post('/open/plex'); },
    'close_plex': function(){ $.post('/close/plex'); },
    'up_arrow': function(){ $.post('/keypress/up_arrow'); },
    'down_arrow': function(){ $.post('/keypress/down_arrow'); }
  };

  $(function(){
    $('body').on('click',function(e){
      ID_ACTIONS[e.target.getAttribute('id')].call(e.target);
    });
  });

}(jQuery));
