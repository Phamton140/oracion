class RoutePaths {
  const RoutePaths._();

  static const String home = '/';
  static const String chat = '/chat';
  static const String chatConversation = '/chat/:conversationId';
  static const String history = '/history';
  static const String favorites = '/favorites';
  static const String reader = '/reader';
  static const String readerChapter = '/reader/:bookNumber/:chapter';
  static const String settings = '/settings';
  static const String about = '/about';

  // Builders
  static String chatFor(int conversationId) => '/chat/$conversationId';
  static String readerFor(int bookNumber, int chapter) =>
      '/reader/$bookNumber/$chapter';
}
