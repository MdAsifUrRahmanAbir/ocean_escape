import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_services.dart';
import '../core/game/game_state.dart';
import '../core/game/ocean_escape_game.dart';
import '../ui/game_overlays.dart';
import '../ui/hud.dart';

/// Hosts the [OceanEscapeGame] Flame widget plus its Flutter-side HUD and
/// state-driven overlays (countdown / pause / game-over) (§32/§34/§35/§50).
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.services});
  final AppServices services;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final OceanEscapeGame game;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    game = OceanEscapeGame(
      settingsManager: widget.services.settings,
      scoreManager: widget.services.score,
      audioManager: widget.services.audio,
      hapticsManager: widget.services.haptics,
      adService: widget.services.ads,
      shopManager: widget.services.shop,
    );
  }

  @override
  void dispose() {
    // Bank gold if the player leaves via system back from game-over.
    game.endRun();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    if (event.logicalKey != LogicalKeyboardKey.space) return;
    if (event is KeyDownEvent) {
      game.setHolding(true);
    } else if (event is KeyUpEvent) {
      game.setHolding(false);
    }
  }

  void _goHome() {
    game.endRun();
    game.resumeEngine();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKey,
        child: Listener(
          onPointerDown: (_) => game.setHolding(true),
          onPointerUp: (_) => game.setHolding(false),
          onPointerCancel: (_) => game.setHolding(false),
          // StackFit.expand: without it, a Stack whose only non-Positioned
          // child is small (the ListenableBuilder can return SizedBox.shrink)
          // collapses to that child's size under Scaffold.body's loose
          // constraints - which in turn collapses every Positioned.fill
          // child (including GameWidget) to zero size, so Flame's
          // GameWidget never sees a non-zero layout and onLoad() never runs.
          child: Stack(
            fit: StackFit.expand,
            children: [
              GameWidget(game: game),
              Hud(game: game, onPause: game.pauseGame),
              ListenableBuilder(
                listenable: game.stateNotifier,
                builder: (context, _) {
                  switch (game.stateNotifier.state) {
                    case GameState.ready:
                      return CountdownOverlay(game: game);
                    case GameState.paused:
                      return PauseOverlay(game: game, onHome: _goHome);
                    case GameState.gameOver:
                      return GameOverOverlay(game: game, onHome: _goHome);
                    case GameState.loading:
                    case GameState.playing:
                    case GameState.crashed:
                    case GameState.restarting:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
