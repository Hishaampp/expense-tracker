import 'package:app_links/app_links.dart';

/// Links that open the app, such as expensetracker://add from the iPhone
/// lock-screen widget.
abstract interface class AppLinkSource {
  /// The link that launched the app, if any.
  Future<Uri?> initial();

  /// Links that arrive while the app is running.
  Stream<Uri> get links;
}

/// [AppLinkSource] over `app_links`.
class PlatformAppLinkSource implements AppLinkSource {
  /// Creates the source.
  new([AppLinks? appLinks]) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;

  @override
  Future<Uri?> initial() => _appLinks.getInitialLink();

  @override
  Stream<Uri> get links => _appLinks.uriLinkStream;
}
