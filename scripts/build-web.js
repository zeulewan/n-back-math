const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const web = path.join(root, "apps", "web");
const dist = path.join(root, "dist");
const files = ["index.html", "privacy.html", "style.css", "app.js"];

fs.rmSync(dist, { recursive: true, force: true });
fs.mkdirSync(dist, { recursive: true });

for (const file of files) {
  fs.copyFileSync(path.join(web, file), path.join(dist, file));
}

fs.cpSync(path.join(web, "assets"), path.join(dist, "assets"), {
  recursive: true,
});
