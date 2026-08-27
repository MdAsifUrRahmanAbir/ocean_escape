import 'package:flutter/foundation.dart';

/// Explicit game states (§42) instead of scattered booleans.
enum GameState { loading, ready, playing, paused, crashed, gameOver, restarting }

/// Thin [ChangeNotifier] wrapper around [GameState] so both [OceanEscapeGame]
/// and Flutter overlay widgets (HUD, pause menu, game-over panel) can react
/// to state changes without polling every frame (§42/§43).
class GameStateNotifier extends ChangeNotifier {
  GameState _state = GameState.loading;
  GameState get state => _state;

  void set(GameState next) {
    if (_state == next) return;
    _state = next;
    notifyListeners();
  }
}
