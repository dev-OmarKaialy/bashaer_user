enum RequestStatus { loading, success, failed, init, needAuth, authed }

extension RequestStatusExtension on RequestStatus {
  // Convert enum to a string
  String toMap() {
    return toString().split('.').last; // Extract the enum name
  }

  // Convert a string to an enum
  bool get isLoading => this == RequestStatus.loading;
  bool get isSuccess => this == RequestStatus.success;
  bool get isFailed => this == RequestStatus.failed;
  bool get isInit => this == RequestStatus.init;
  bool get needAuth => this == RequestStatus.needAuth;
  bool get isAuth => this == RequestStatus.authed;
}

extension RequestStatusExtensionString on String {
  RequestStatus toRequestStatus() {
    return RequestStatus.values.firstWhere(
      (e) => e.toString().split('.').last == this,
      orElse: () => RequestStatus.init, // Default value
    );
  }
}
