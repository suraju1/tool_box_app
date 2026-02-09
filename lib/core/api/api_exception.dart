/// Base class for all API exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends ApiException {
  NetworkException(
      [super.message = 'No internet connection. Please check your network.']);
}

/// Exception thrown when the request times out
class TimeoutException extends ApiException {
  TimeoutException([super.message = 'Request timed out. Please try again.']);
}

/// Exception thrown when the server returns an error (4xx, 5xx)
class ServerException extends ApiException {
  ServerException(super.message, {super.statusCode});
}

/// Exception thrown when there's a validation error
class ValidationException extends ApiException {
  ValidationException(super.message);
}

/// Exception thrown when authentication fails
class UnauthorizedException extends ApiException {
  UnauthorizedException(
      [super.message = 'Session expired. Please login again.'])
      : super(statusCode: 401);
}

/// Exception thrown when the response cannot be parsed
class ParseException extends ApiException {
  ParseException([super.message = 'Failed to parse server response.']);
}

/// Exception thrown for unknown errors
class UnknownException extends ApiException {
  UnknownException(
      [super.message = 'An unexpected error occurred. Please try again.']);
}
