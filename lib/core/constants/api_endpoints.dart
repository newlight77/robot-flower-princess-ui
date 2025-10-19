class ApiEndpoints {
  static const String games = '/api/games';
  static String game(String id) => '/api/games/$id';
  static String gameAction(String id) => '/api/games/$id/action';
  static String autoPlay(String id) => '/api/games/$id/autoplay';
  static String replay(String id) => '/api/games/$id/replay';
}
