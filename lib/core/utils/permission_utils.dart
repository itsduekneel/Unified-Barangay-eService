import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  /// Requests all necessary permissions for the project.
  static Future<void> requestAllPermissions() async {
    // Internet permission is handled automatically by Android,
    // but Location and Notifications need runtime requests.

    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.notification,
    ].request();

    if (statuses[Permission.location]!.isDenied) {
      // Handle denied location
    }

    if (statuses[Permission.notification]!.isDenied) {
      // Handle denied notifications
    }
  }

  static Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }

  static Future<bool> hasNotificationPermission() async {
    return await Permission.notification.isGranted;
  }
}
