Appcanary.api_key = ENV["APPCANARY_API_KEY"] || "api key not set"
Appcanary.disable_mocks = -> {
  WebMock.disable! if defined?(WebMock)
}
