import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../piano/presentation/pages/piano_detail_screen.dart';
import '../../../piano/presentation/widgets/piano_card_widget.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FavoritesBloc(repository: sl())..add(LoadFavorites()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đàn yêu thích'),
        ),
        body: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FavoritesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<FavoritesBloc>().add(LoadFavorites()),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            } else if (state is FavoritesLoaded) {
              final favorites = state.favorites;

              if (favorites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Danh sách yêu thích trống', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75, // Shortened from 0.65
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final piano = favorites[index];
                  return PianoCardWidget(
                    piano: piano,
                    isFavorited: true, // It's in favorites so it's favorited
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PianoDetailScreen(pianoId: piano.id),
                        ),
                      );
                    },
                    onFavoriteTap: () {
                      context.read<FavoritesBloc>().add(RemoveFavorite(piano.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã bỏ thích đàn khỏi danh sách')),
                      );
                    },
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
