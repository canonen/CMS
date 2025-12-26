const express = require('express');
const https = require('https');
const fs = require('fs');
const axios = require('axios');
const bodyParser = require('body-parser');
const options = {
    key: fs.readFileSync('cert_key.pem'),
    cert: fs.readFileSync('cert.pem')
};
const puppeteer = require('puppeteer');
const app = express();
var cors = require('cors')
app.use(cors())
const port = 3004;

// Body parser middleware
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

// GET endpoint for fetching source code of a given URL


app.get('/', async (req, res) => {
	axios.get("https://cms.revotas.com/cms/ui/jsp/newlogin.jsp?company=revotaskurumsal&login=radmin&password=4t4turk1915!")
	.then(async (resp) => {
		console.log(resp.data)
		const  url  = req.query.param;
		
	setTimeout(async()=>{


			async function getWebsiteSource(url) {
				const browser = await puppeteer.launch(); // Tarayıcıyı başlat
				const page = await browser.newPage(); // Yeni bir sayfa oluştur

				await page.goto(url); // Belirtilen URL'ye git
				const source = await page.content(); // Sayfanın kaynak kodunu al

				await browser.close(); // Tarayıcıyı kapat

				return source;
			}

			// Kullanım
			const websiteUrl = url;
			getWebsiteSource(websiteUrl)
				.then(source => {
					console.log(websiteUrl)
					res.send(source);
					console.log('Web sitesi kaynak kodu:', source);
				})
				.catch(error => {
					console.error('Hata:', error);
				});

		/*
		try {
			// Fetching the source code of the provided URL
			const response = await axios.get(url);
			const sourceCode = response.data;
			res.status(200).json({ sourceCode });
		} catch (error) {
			console.log(error)
			res.status(500).json({ error: 'Error fetching source code.' });
		}
		*/
	},2000)
		
	})
	

   
});

// Starting the server
https.createServer(options, app).listen(3004);
