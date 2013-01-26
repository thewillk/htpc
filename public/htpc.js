(function($){
  var ID_ACTIONS = {
    'open_hulu': function(){ $.post('/open/hulu_desktop'); },
    'close_hulu': function(){ $.post('/close/hulu_desktop'); },
    'open_plex': function(){ $.post('/open/plex'); },
    'close_plex': function(){ $.post('/close/plex'); },
    'subwoofer_on': function(){ $.post('/wemo_switch/subwoofer/on'); },
    'subwoofer_off': function(){ $.post('/wemo_switch/subwoofer/off'); },
    'up_arrow': function(){ $.post('/keypress/up_arrow'); },
    'down_arrow': function(){ $.post('/keypress/down_arrow'); }
  };

  $(function(){
    var $body = $('body');

    $body.on('click',function(e){
      var id = e.target.getAttribute('id');
      if(ID_ACTIONS[id] && ID_ACTIONS[id].call){
        ID_ACTIONS[id].call(e.target);
      }
    });

    var modifier_data = function(event) {
      var modifiers = {};

      if(event.ctrlKey) {
        modifiers['control'] = 'true';
      }
      if(event.altKey) {
        modifiers['option'] = 'true';
      }
      if(event.shiftKey) {
        modifiers['shift'] = 'true';
      }
      if(event.metaKey) {
        modifiers['command'] = 'true';
      }

      return modifiers;
    };

    $body.on('keydown',function(e){
      var IGNORE_KEYS = [0,16,17,18,91],
        COMMAND_KEYS = {
          '8': 'delete',
          '13': 'enter',
          '27': 'esc',
          '32': 'space',
          '37': 'right_arrow',
          '38': 'up_arrow',
          '39': 'left_arrow',
          '40': 'down_arrow'
        },
        url,
        data;

      if(IGNORE_KEYS.indexOf(e.keyCode)!==-1) return;

      if(COMMAND_KEYS[e.keyCode] !== undefined) {
        url = "/keypress/"+COMMAND_KEYS[e.keyCode];
      }
      else if( (e.keyCode>=65)&&(e.keyCode<=90) ){
        url = "/type/"+String.fromCharCode(e.keyCode).toLowerCase();
      }
      else {
        return;
      }

      e.preventDefault();

      data = modifier_data(e);
      if(data.length>0) {
        url = url + '?' + data;
      }

      $.post(url,data);
    });

    $body.on('keypress',function(e){
      var url = "/type/"+encodeURIComponent(String.fromCharCode(e.keyCode).toLowerCase()),
        data = modifier_data(e);

      e.preventDefault();

      $.post(url,data);
    });
  });

}(jQuery));
