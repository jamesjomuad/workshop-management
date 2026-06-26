import { chromium } from 'playwright';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });

const errors = [];
page.on('console', msg => {
  if (msg.type() === 'error') errors.push(msg.text());
});
page.on('pageerror', err => errors.push(err.message));

try {
  await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle', timeout: 15000 });
} catch (e) {
  console.log('Navigation error:', e.message);
}

await page.waitForTimeout(2000);

if (await page.locator('.form-wrapper').count() > 0) {
  const visible = await page.locator('.form-wrapper.visible').count();
  console.log('Form wrapper exists, visible:', visible > 0);
} else {
  console.log('Form wrapper NOT found');
}
if (await page.locator('input').count() > 0) {
  console.log('Input fields found:', await page.locator('input').count());
} else {
  console.log('No input fields');
}
if (await page.locator('button').count() > 0) {
  console.log('Buttons found:', await page.locator('button').count());
} else {
  console.log('No buttons');
}
console.log('Page title:', await page.title());
console.log('Body HTML length:', await page.evaluate(() => document.body?.innerHTML?.length || 0));

if (errors.length > 0) {
  console.log('Console errors:');
  errors.forEach(e => console.log('  -', e));
}

await page.screenshot({ path: 'login-page.png', fullPage: true });
console.log('Screenshot saved to login-page.png');
await browser.close();
