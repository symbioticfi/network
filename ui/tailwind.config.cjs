/** @type {import('tailwindcss').Config} */
const path = require("path");

module.exports = {
  // Absolute paths so Tailwind finds files regardless of CWD
  content: [path.join(__dirname, "index.html"), path.join(__dirname, "src/**/*.{ts,tsx,js,jsx}")],
  theme: {
    extend: {},
  },
  plugins: [],
};
