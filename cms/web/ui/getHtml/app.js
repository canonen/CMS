var express = require('express');
var app = express();
var axios = require('axios');
const fs = require('fs'); 
var cors = require('cors')
const https = require('https');
app.use(cors())
const options = {   
key: fs.readFileSync('cert_key.pem'),   
cert: fs.readFileSync('cert.pem') 
}; 


app.get('/', async function (req, res, next) {

   axios.get(req.query.url)
   .then((resp) => res.send(resp.data))
   //.then((resp) => res.send(resp));

})

;

https.createServer(options, app).listen(3003);

