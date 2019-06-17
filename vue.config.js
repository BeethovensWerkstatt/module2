module.exports = {
  css: {
    loaderOptions: {
      sass: {
        // global sass files, available in every style elem with lang="scss"
        data: '@import "@/sass/_variables.scss";'
      }
    }
  }
}
