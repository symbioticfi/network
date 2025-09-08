module.exports = {
  plugins: {
    // Resolve config path regardless of CWD
    tailwindcss: { config: __dirname + '/tailwind.config.cjs' },
    autoprefixer: {},
  },
}
