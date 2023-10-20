String timeAgoDifference(int eventCreatedAt) {
  final dateNow = DateTime.now();
  final eventTime = DateTime.fromMillisecondsSinceEpoch(eventCreatedAt * 1000);

  // secs
  int timeAgo = dateNow.difference(eventTime).inSeconds;
  String timeAgoRef = "secs.";
  if (timeAgo == 1) timeAgoRef = "sec.";

  // mins
  if (timeAgo >= 60) {
    timeAgo = dateNow.difference(eventTime).inMinutes;
    timeAgoRef = "mins.";
    if (timeAgo == 1) timeAgoRef = "min.";
  }

  // hours
  if (timeAgo >= 60) {
    timeAgo = dateNow.difference(eventTime).inHours;
    timeAgoRef = "hrs.";
    if (timeAgo == 1) timeAgoRef = "hr.";
  }

  return "$timeAgo $timeAgoRef";
}
