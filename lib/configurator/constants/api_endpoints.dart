class ApiEndpoints {
  static const String games = '/api/games/';
  static String game(String id) => '/api/games/$id';
  static String gameHistory(String id) => '/api/games/$id/history';
  static String gameAction(String id) => '/api/games/$id/action';
  static String autoPlay(String id) => '/api/games/$id/autoplay';
}
