
const https = require('https');
const fs = require('fs');
const options = {
    key: fs.readFileSync('cert_key.pem'),
    cert: fs.readFileSync('cert.pem')
};
const { Builder } = require("selenium-webdriver");
const x = require("selenium-webdriver");
//require("chromedriver");
var express = require('express');
var app = express();

var cors = require('cors')
app.use(cors())


app.get('/', async function (req, res, next) {

    let driver = await new x.Builder().forBrowser("chrome").build();
    let isMobile = req.query.isMobile;
    try {
        if (req.query.url === "") {
            await driver.get("https://getbootstrap.com/docs/4.0/examples/album/");
        } else {
            await driver.get(req.query.url);
        }
        if (isMobile === "true") {
            driver.manage().window().setRect({ x: 0, y: 0, width: 450, height: 999 });
        } else {
            driver.manage().window().maximize();
        }
        let image;
        setTimeout(async () => {
            image = await driver.takeScreenshot();
            res.send(image);
            driver.close();
        }, 1000)
    } catch (error) {
        if (req.query.url === "") {
            await driver.get("https://getbootstrap.com/docs/4.0/examples/album/");
        } else {
            await driver.get(req.query.url);
        }
        if (isMobile === "true") {
            driver.manage().window().setRect({ x: 0, y: 0, width: 450, height: 999 });
        } else {
            driver.manage().window().maximize();
        }
        let image;
        setTimeout(async () => {
            image = await driver.takeScreenshot();
            res.send(image);
            driver.close();
        }, 1000)
    }
    

})

function base64_encode(file) {
    var bitmap = fs.readFileSync(file);
    return new Buffer(bitmap).toString('base64');
}

https.createServer(options, app).listen(3000);


