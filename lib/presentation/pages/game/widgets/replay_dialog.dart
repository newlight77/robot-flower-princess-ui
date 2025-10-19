import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/game_board.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/game_board_widget.dart';

class ReplayDialog extends ConsumerStatefulWidget {
  final String gameId;

  const ReplayDialog({
    required this.gameId, super.key,
  });

  @override
  ConsumerState<ReplayDialog> createState() => _ReplayDialogState();
}

class _ReplayDialogState extends ConsumerState<ReplayDialog> {
  List<GameBoard>? _boardStates;
  int _currentStep = 0;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReplay();
  }

  Future<void> _loadReplay() async {
    final replayUseCase = ref.read(replayGameUseCaseProvider);
    final result = await replayUseCase(widget.gameId);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _error = failure.message;
          _isLoading = false;
        });
      },
      (boards) {
        setState(() {
          _boardStates = boards;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
            if (_boardStates != null) _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle_outline, color: Colors.white),
          const SizedBox(width: 12),
          const Text(
            'Game Replay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    if (_boardStates == null || _boardStates!.isEmpty) {
      return const Center(
        child: Text('No replay data available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GameBoardWidget(
        board: _boardStates![_currentStep],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Text(
            'Step ${_currentStep + 1} / ${_boardStates!.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            value: _currentStep.toDouble(),
            min: 0,
            max: (_boardStates!.length - 1).toDouble(),
            divisions: _boardStates!.length - 1,
            onChanged: (value) {
              setState(() {
                _currentStep = value.toInt();
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: _currentStep > 0
                    ? () => setState(() => _currentStep = 0)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentStep > 0
                    ? () => setState(() => _currentStep--)
                    : null,
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 36,
                onPressed: _togglePlayback,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentStep < _boardStates!.length - 1
                    ? () => setState(() => _currentStep++)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: _currentStep < _boardStates!.length - 1
                    ? () => setState(() => _currentStep = _boardStates!.length - 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _togglePlayback() {
    if (_isPlaying) {
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      _playReplay();
    }
  }

  Future<void> _playReplay() async {
    while (_isPlaying && _currentStep < _boardStates!.length - 1) {
      await Future.delayed(AppConstants.replayStepDuration);
      if (!mounted || !_isPlaying) break;
      setState(() => _currentStep++);
    }
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }
}
