enum ApplicationEnvironment { staging, development, production }

abstract class APIEndPoints {
  static ApplicationEnvironment environment = ApplicationEnvironment.staging;

  static String baseUrl = 'http://3.122.9.220:6477/api/v1/';
  static String login = 'user/login';
}
