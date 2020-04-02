var express = require('express');
var app = express()
var http = require('http').createServer(app);
var io = require('socket.io')(http);
var path = require('path');
var axios = require('axios');

function fetchQuestions(cb) {
 axios.get('https://opentdb.com/api.php?amount=1&difficulty=hard&type=multiple&encode=url3986').then(function (data) {
  cb(data.data);
})
}

const config = {
 code: "divy"
}

app.use(express.static(path.join(__dirname, '../interface/bin')));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../interface/bin/index.html'))
});

var ques;
var players = [];
var allReady = [];
var answerReady = [];
var pointReady = [];
var totalScores = {};
var totalQuestions = 2;
var allQuestions = [];
io.on('connection', function(socket){
  socket.on('join', function(data) {
    console.log(data);
    if(data.code.trim().toLowerCase() == config.code) {
      players.push({ username: data.user });
      totalScores[data.username] = 0;
      console.log(`${data.user} just joined.`)
      io.sockets.emit('joined', { players: players });
    }
  });
  socket.on('ask', function(data) {
    allReady.push(data);
    if(allReady.length == players.length) {
      fetchQuestions((a) => {
        io.sockets.emit('question', a);
        ques = a;
        allQuestions.push(a);
      })
      while(allReady.length > 0) {
        allReady.pop();
      }

    } 
  });
 socket.on('point', function(data) {
   var exists = false;
   for(var i=0;i<pointReady.length;i++) {
     if(pointReady[i].username == data.username) { exists=true; break; }
   }
   if(!exists) {
     pointReady.push(data);
     totalScores[data.username] = totalScores[data.username] + data.point;
   } 
   if(pointReady.length == players.length) {
     io.sockets.emit('results', { points: pointReady })
      while(pointReady.length > 0) {
        pointReady.pop();
      }
    if(allQuestions.length == totalQuestions) {
      console.log('Game over :)');
      io.sockets.emit('game-over', pointReady);
    }
   }
 });
 socket.on('answer', function(data) {
   var exists = false;
   for(var i=0;i<answerReady.length;i++) {
     if(answerReady[i].user == data.user) { exists=true; break; }
   }
   if(!exists) answerReady.push(data);
   console.log('answerReady: '+answerReady);
   console.log('players: '+players);
   if(answerReady.length == players.length) {
      io.sockets.emit('answer-data', {answers: answerReady, correct: ques.correctAnswer})
      while(answerReady.length > 0) {
        answerReady.pop();
      }
    }
 });
});

http.listen(3000, function(){
  console.log('listening on *:3000');
});
