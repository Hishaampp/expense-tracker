/// How long after a local change sync waits for more (Phase 9).
const Duration syncDebounce = Duration(seconds: 3);

/// How often sync runs while the app is open (Phase 9).
const Duration syncInterval = Duration(minutes: 15);

/// How long a request to the account server may take.
const Duration cloudRequestTimeout = Duration(seconds: 10);
