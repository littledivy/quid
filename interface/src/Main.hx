package;

import Random;
import js.jquery.*;
import js.Browser.*;
import js.node.socketio.*;

class Game {
  public function new() { }
  public function start(client: Client, username: String) {
    new JQuery("#lobby").hide();
    client.emit('ask', {});
    var q;
    client.on('question', function(data) {
      new JQuery("#question")[0].innerHTML = untyped decodeURIComponent(data.results[0].question);
      new JQuery("#game-board").show();
      q = untyped decodeURIComponent(data.results[0].correct_answer);
    });
    client.on('results' ,function(data) {
      new JQuery("#winner-append")[0].innerHTML = '';
      for(x in 0...Reflect.fields(data.points).length) {
        new JQuery("#winner-append").append('<h3>${data.points[x].username} - ${data.points[x].point}</h3><br>');
      };
      new JQuery("#winner").show();
    });
    client.on('game-over' ,function(data) {
      var sortedArray = data.sort(function (a,b) return untyped parseFloat(b["points"]) - untyped parseFloat(a["points"]));
      trace(sortedArray);
      new JQuery("#winner").hide();
      new JQuery("#final-winner")[0].innerHTML = '<b>${sortedArray[0].username} wins with ${sortedArray[0].points}<b>';
      new JQuery("#game-over").show();
    });
    client.on('answer-data', function(data) {
       new JQuery("#game-board").hide();
       new JQuery('#answers-append')[0].innerHTML = '';
       new JQuery('#answers-append').append('<button type="button" class="btn btn-block btn-radius btn-info" id="answer-c">${q}</button>');
       for(x in 0...Reflect.fields(data.answers).length) {
          trace(data.answers[x]);
          new JQuery('#answers-append').append('<button type="button" class="btn btn-block btn-radius btn-info" id="answer-w">${data.answers[x].answer}</button>');
        };
         new JQuery("#answer-c").on("click", function (event) {
      trace('click');
      new JQuery("#answer-board").hide();
      client.emit('point', {point: 1, username: username});
    });
   new JQuery("#answer-w").on("click", function (event) {
      new JQuery("#answer-board").hide();     
      client.emit('point', {point: 0, username: username});
    });  
     /**     var divs = new JQuery('#answers-append').children();
          while(divs.length) {
            new JQuery('#answers-append').append(divs.splice(Math.floor(Math.random() * divs.length), 1)[0]);
          }; **/
       untyped new JQuery('#answers-append').randomize();
       new JQuery("#answer-board").show();
     });            
    new JQuery("#answer-button").on("click", function (event) {
      var answer = new JQuery("#answer").val();
      new JQuery("#game-board").hide();
      client.emit('answer', { user:username, answer:answer });
    });
 } 
}
/**
class Session {
  var username: String;
  public function new(username) { 
    this.username = username;
  }
  public function get(): String {
    return username;
  }
}
**/
class Join {
  public function new() { }
  public function join(username: String, client: Client, code) {
    trace('username: $username');
    client.emit('join', { user: username, code: code });
    client.on('joined', function (data) { 
      trace(data);
      new JQuery('#choose').hide();
      new JQuery('#lobby').show();
      new JQuery('#players')[0].innerHTML = '';
      for(x in 0...Reflect.fields(data.players).length) {
        new JQuery('#players').append('<h3>${data.players[x].username}</h3>');
      };
      new JQuery( "#start-game" ).on( "click", function ( event ) {
         var newGame = new Game();
         newGame.start(client, username);
      });
  
    });
  }; 
}

class Main {
  // Haxe applications have a static entry point called main
  static function main() {
    new JQuery(function():Void {
      var joinGame = new Join();
      var username: String;
      new JQuery( "#join" ).on( "click", function( event ) {
        username = new JQuery( "#username" ).val();
        new JQuery( "#welcome-user" )[0].innerHTML = 'Welcome $username!';
        new JQuery('#choose').show(); 
        new JQuery('#login').hide();
      });
      new JQuery( "#join-game" ).on( "click", function ( event ) {
         var cl = new Client("/");
         var code = new JQuery( "#code" ).val();
         joinGame.join(username, cl, code);
      });
    });
  }
}
            
// Allow anonymous structure named as type.
typedef Player = { name: String, move: Move }

// Define multiple enum values.
enum Move { Rock; Paper; Scissors; }

// Enums in Haxe are algebraic data type (ADT), so they can hold data.
enum Result { 
  Winner(player:Player); 
  Draw; 
}
