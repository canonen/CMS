const puppeteer = require("puppeteer");
puppeteer
  .launch({
    defaultViewport: {
      width: 1280,
      height: 2000,
    },
  })
  .then(async (browser) => {
    const page = await browser.newPage();
    await page.goto("https://nytimes.com");
    await page.screenshot({ path: "nyt-puppeteer.png" });
    await browser.close();
  });