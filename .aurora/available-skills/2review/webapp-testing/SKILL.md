---
name: webapp-testing
description:
  Toolkit for interacting with and testing local web applications using Playwright. Supports
  verifying frontend functionality, debugging UI behavior, capturing browser screenshots, and
  viewing browser logs.
---

# Web Application Testing

This skill enables comprehensive testing and debugging of local web applications using Playwright
automation.

## When to Use This Skill

Use this skill when you need to:

- Test frontend functionality in a real browser
- Verify UI behavior and interactions
- Debug web application issues
- Capture screenshots for documentation or debugging
- Inspect browser console logs
- Validate form submissions and user flows
- Check responsive design across viewports

## Prerequisites

- Node.js installed on the system
- A locally running web application (or accessible URL)
- Playwright will be installed automatically if not present

## Core Capabilities

### 1. Browser Automation

- Navigate to URLs
- Click buttons and links
- Fill form fields
- Select dropdowns
- Handle dialogs and alerts

### 2. Verification

- Assert element presence
- Verify text content
- Check element visibility
- Validate URLs
- Test responsive behavior

### 3. Debugging

- Capture screenshots
- View console logs
- Inspect network requests
- Debug failed tests

## Usage Examples

### Example 1: Basic Navigation Test

```javascript
// Navigate to a page and verify title
await page.goto("http://localhost:3000");
const title = await page.title();
console.log("Page title:", title);
```

### Example 2: Form Interaction

```javascript
// Fill out and submit a form
await page.fill("#username", "testuser");
await page.fill("#password", "password123");
await page.click('button[type="submit"]');
await page.waitForURL("**/dashboard");
```

### Example 3: Screenshot Capture

```javascript
// Capture a screenshot for debugging
await page.screenshot({ path: "debug.png", fullPage: true });
```

## Guidelines

1. **Always verify the app is running** - Check that the local server is accessible before running
   tests
1. **Always verifty the backend is running** - You must always start the .net backend before running
   tests
1. **Use explicit waits** - Wait for elements or navigation to complete before interacting
1. **Capture screenshots on failure** - Take screenshots to help debug issues
1. **Clean up resources** - Always close the browser when done
1. **Handle timeouts gracefully** - Set reasonable timeouts for slow operations
1. **Test incrementally** - Start with simple interactions before complex flows
1. **Use selectors wisely** - Prefer data-testid or role-based selectors over CSS classes
1. **Prefer Edge**- Chromium for testing - It provides better compatibility with modern web
   features, do not use Chrome or Firefox. Include WebKit only if testing for Safari is required.
1. **Work directory** - The root directory for frontend is `/src/frontend/`, ensure all commands are
   run from there if you are not already in this directory.

## Common Patterns

### Pattern: Wait for Element

```javascript
await page.waitForSelector("#element-id", { state: "visible" });
```

### Pattern: Check if Element Exists

```javascript
const exists = (await page.locator("#element-id").count()) > 0;
```

### Pattern: Get Console Logs

```javascript
page.on("console", (msg) => console.log("Browser log:", msg.text()));
```

### Pattern: Handle Errors

```javascript
try {
  await page.click("#button");
} catch (error) {
  await page.screenshot({ path: "error.png" });
  throw error;
}
```

## Limitations

- Requires Node.js environment
- Cannot test native mobile apps (use React Native Testing Library instead)
- May have issues with complex authentication flows
- Some modern frameworks may require specific configuration
