var express = require('express');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);

http.listen(3000, function() {
	console.log('Listening on :3000');
});

var Rooms = {};

io.sockets.on('connection', function(socket) {
	
	socket.on('create-room', function(person) {
		// Generate the room id
		var roomId = genId();
		
		console.log('create-room with id: ' + roomId);
		
		// Create a db for the room
		Rooms.roomId = [];
		
		// Notify the room has been created and send back the room Id
		socket.emit('created-room', {roomId: roomId}) 

		setTimeout(function() {
			io.sockets.in(roomId).emit('room-closed', {roomId: roomId});
		}, 1000 * 60)
	});

	socket.on('join-room', function(person, roomId) {
		console.log('join-room');
		console.log(person)
		// Send this persons info to everyone in the room
		io.sockets.in(roomId).emit('person-joined', {person: person})
		
		// Send all the people in the current room as response
		socket.emit('joined-room', {people: Rooms.roomId});
		
		// Add this person to the db
		Rooms.roomId.push(person);
		
		// Join the socket room
		socket.join(roomId)
	});
	console.log("Connected");
	socket.emit('connected', { msg: 'Socket Connected'});
});

function genId() {
	var id = "" + randomInt(0, 5);
	for(var i = 0; i < 4; i++) {
		id = id + randomInt(0, 9);	
	}
	return id;
}

function randomInt(low, high) {
    return Math.floor(Math.random() * (high - low + 1) + low);
}
















