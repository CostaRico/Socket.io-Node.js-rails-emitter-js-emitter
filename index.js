var app = require('express')();
var http = require('http').Server(app);

var redis = require('redis');
var redisAdapter = require('socket.io-redis');
var pub = redis.createClient(null, null, {
    return_buffers: true
});
var sub = redis.createClient(null, null, {
    detect_buffer: true, return_buffers: true
});

// 1
http.listen(8009, function() {
    console.log('listening on *:');
});


var io = require('socket.io')(http, {
    adapter: redisAdapter({
        pubClient: pub,
        subClient: sub
    })
});



// 2

io.on('connection', function(socket) {


    console.log('a user connected');
    // console.log(socket);

    socket.broadcast.emit('hi');
    socket.on('disconnect', function() {
        console.log('user disconnected');
    });
    socket.on('chat message', function(msg) {
        console.log('message: ' + msg);
        io.emit('chat message', msg);
    });


    socket.on('time', function(msg) {
        console.log('time got')
        io.emit('chat message', msg);
    });




    socket.on('private channel', (data) => {
        console.log('PRIVATE CHANNEL');
        console.log(data.id);
         socket.join(data.id);
        // console.log(data);
    })
});


//
// io.of('/emitter').on('connection', function(socket) {
//     console.log('Emitter channel contcted')
//     socket.on('chat message', data => {
//         //console.log(data);
//     });
// })


//['/', '/nsp'].forEach(function(nsp) {
// io.of('/nsp').on('connection', function(socket) {
//     console.log('connected /nsp');
//     socket.on('broadcast event', function(payload) {
//         socket.emit('broadcast event', payload);
//     });
// });
//});


//need   socket.io#/emitter#
//exists socket.io#/emitter#

app.get('/', function(req, res) {
    res.sendfile('./index.html');
});
