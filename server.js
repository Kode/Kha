/*jshint node:true*/

//------------------------------------------------------------------------------
// node.js starter application for Bluemix
//------------------------------------------------------------------------------

// This application uses express as it's web server
// for more info, see: http://expressjs.com
var express = require('express');

// create a new express server
var app = express();

// serve the files out of ./public as our main files
app.use(express.static(__dirname + '/public'));

// set the view engine to ejs
app.set('view engine', 'ejs');

// INDEX page
app.get('/', function(req, res) {

    res.render('pages/index');
});

// DOWNLOAD page
app.get('/download', function(req, res) {

    res.render('pages/download');
});

// GETSTARTED -> INSTALL page
app.get('/getstarted/install', function(req, res) {

    res.render('pages/install');
});

// GETSTARTED -> CREATE page
app.get('/getstarted/create', function(req, res) {

    res.render('pages/create');
});

// GETSTARTED -> BUILD page
app.get('/getstarted/build', function(req, res) {

    res.render('pages/build');
});

app.set('port', process.env.OPENSHIFT_NODEJS_PORT || process.env.PORT || 3002);
app.set('ip', process.env.OPENSHIFT_NODEJS_IP || "127.0.0.1");

// start server on the specified port and binding host
app.listen(app.get('port'), app.get('ip'), function() {

    // print a message when the server starts listening
    console.log("✔ Express server listening at %s:%d ", app.get('ip'),app.get('port'));
});