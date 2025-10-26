import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../configurator/constants/app_constants.dart';
import '../../../../hexagons/game/domain/entities/game.dart';
import '../../../providers/game_provider.dart';

class CreateGameDialog extends ConsumerStatefulWidget {
  final Function(Game) onGameCreated;

  const CreateGameDialog({
    required this.onGameCreated,
    super.key,
  });

  @override
  ConsumerState<CreateGameDialog> createState() => _CreateGameDialogState();
}

class _CreateGameDialogState extends ConsumerState<CreateGameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _boardSize = AppConstants.defaultBoardSize;
  bool _isLoading = false;

  // List of fun words for random game names
  static const _nameWords = [
    'Adventure', 'Quest', 'Journey', 'Mission', 'Challenge',
    'Expedition', 'Voyage', 'Trek', 'Odyssey', 'Safari',
    'Discovery', 'Exploration', 'Campaign', 'Venture', 'Pursuit',
    'Hunt', 'Search', 'Trial', 'Test', 'Conquest',
    'Victory', 'Glory', 'Legend', 'Epic', 'Saga',
    'Tale', 'Story', 'Chronicle', 'Riddle', 'Puzzle',
    'Mystery', 'Secret', 'Wonder', 'Marvel', 'Treasure',
    'Garden', 'Paradise', 'Kingdom', 'Realm', 'Empire',
    'Fantasy', 'Dream', 'Magic', 'Enchant', 'Mystic',
    'Phoenix', 'Dragon', 'Unicorn', 'Griffin', 'Pegasus',
    'Warrior', 'Hero', 'Champion', 'Guardian', 'Sentinel',
    'Knight', 'Ranger', 'Scout', 'Explorer', 'Wanderer',
    'Seeker', 'Voyager', 'Pathfinder', 'Trailblazer', 'Pioneer',
    'Horizon', 'Sunrise', 'Sunset', 'Twilight', 'Dawn',
    'Eclipse', 'Comet', 'Meteor', 'Nova', 'Nebula',
    'Galaxy', 'Cosmos', 'Universe', 'Infinity', 'Eternal',
    'Thunder', 'Lightning', 'Storm', 'Tempest', 'Whirlwind',
    'Blaze', 'Flame', 'Inferno', 'Spark', 'Ember',
    'Crystal', 'Diamond', 'Ruby', 'Sapphire', 'Emerald',
    'Amber', 'Jade', 'Pearl', 'Opal', 'Topaz',
    'Silver', 'Golden', 'Platinum', 'Bronze', 'Copper',
    'Shadow', 'Phantom', 'Spirit', 'Ghost', 'Specter',
    'Angel', 'Demon', 'Titan', 'Giant', 'Colossus',
    'Mountain', 'Valley', 'River', 'Ocean', 'Sea',
    'Forest', 'Desert', 'Tundra', 'Jungle', 'Meadow',
    'Castle', 'Fortress', 'Tower', 'Citadel', 'Bastion',
    'Palace', 'Temple', 'Shrine', 'Sanctuary', 'Haven',
    'Crown', 'Throne', 'Scepter', 'Shield', 'Sword',
    'Arrow', 'Spear', 'Axe', 'Hammer', 'Dagger',
    'Frost', 'Ice', 'Snow', 'Winter', 'Arctic',
    'Summer', 'Spring', 'Autumn', 'Season', 'Solstice',
    'Moon', 'Star', 'Sun', 'Sky', 'Cloud',
    'Rain', 'Wind', 'Mist', 'Fog', 'Haze',
    'Light', 'Dark', 'Bright', 'Glow', 'Shine',
    'Royal', 'Noble', 'Grand', 'Majestic', 'Supreme',
    'Ancient', 'Mystic', 'Sacred', 'Divine', 'Blessed',
    'Wild', 'Savage', 'Fierce', 'Bold', 'Brave',
    'Swift', 'Quick', 'Rapid', 'Fast', 'Nimble',
    'Silent', 'Hidden', 'Secret', 'Lost', 'Forgotten',
    'Rising', 'Falling', 'Soaring', 'Flying', 'Gliding',
    'Eternal', 'Timeless', 'Endless', 'Boundless', 'Limitless',
    'Crimson', 'Azure', 'Violet', 'Scarlet', 'Indigo',
    'Obsidian', 'Onyx', 'Quartz', 'Marble', 'Granite',
    'Raven', 'Eagle', 'Hawk', 'Falcon', 'Owl',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = _generateGameName(_boardSize);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _generateGameName(int boardSize) {
    final random = Random();
    final word1 = _nameWords[random.nextInt(_nameWords.length)];
    final word2 = _nameWords[random.nextInt(_nameWords.length)];
    final word3 = _nameWords[random.nextInt(_nameWords.length)];
    return '${boardSize}x$boardSize-$word1-$word2-$word3';
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
              decoration: InputDecoration(
                labelText: 'Game Name',
                hintText: 'Enter a name for your game',
                prefixIcon: const Icon(Icons.games),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: 'Generate new name',
                  onPressed: () {
                    setState(() {
                      _nameController.text = _generateGameName(_boardSize);
                    });
                  },
                ),
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
                  // Update the name with new board size
                  _nameController.text = _generateGameName(_boardSize);
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
