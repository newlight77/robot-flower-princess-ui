import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/game.dart';
import '../../../providers/game_provider.dart';

class CreateGameDialog extends ConsumerStatefulWidget {
  final Function(Game) onGameCreated;

  const CreateGameDialog({
    super.key,
    required this.onGameCreated,
  });

  @override
  ConsumerState<CreateGameDialog> createState() => _CreateGameDialogState();
}

class _CreateGameDialogState extends ConsumerState<CreateGameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _boardSize = AppConstants.defaultBoardSize;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🎮 Create New Game'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Game Name',
                hintText: 'Enter a name for your game',
                prefixIcon: Icon(Icons.games),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a game name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Board Size: $_boardSize x $_boardSize',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Slider(
              value: _boardSize.toDouble(),
              min: AppConstants.minBoardSize.toDouble(),
              max: AppConstants.maxBoardSize.toDouble(),
              divisions: AppConstants.maxBoardSize - AppConstants.minBoardSize,
              label: '$_boardSize',
              onChanged: (value) {
                setState(() {
                  _boardSize = value.toInt();
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createGame,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createGame() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final createGameUseCase = ref.read(createGameUseCaseProvider);
    final result = await createGameUseCase(_nameController.text, _boardSize);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (game) {
        Navigator.pop(context);
        widget.onGameCreated(game);
      },
    );
  }
}
