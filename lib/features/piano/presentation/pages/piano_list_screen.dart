import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/repositories/piano_repository.dart';
import '../bloc/piano_list_bloc.dart';
import '../bloc/piano_list_event.dart';
import '../bloc/piano_list_state.dart';
import '../widgets/piano_card_widget.dart';
import 'piano_detail_screen.dart';

class PianoListScreen extends StatelessWidget {
  const PianoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Feature BLoC — provide ở cấp Screen, giải phóng RAM khi rời khỏi
    return BlocProvider<PianoListBloc>(
      create: (_) => PianoListBloc(pianoRepository: di.sl<PianoRepository>())..add(LoadPianos()),
      child: const _PianoListView(),
    );
  }
}

class _PianoListView extends StatefulWidget {
  const _PianoListView();

  @override
  State<_PianoListView> createState() => _PianoListViewState();
}

class _PianoListViewState extends State<_PianoListView> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.cardWhite,
        elevation: 0,
        title: _isSearching
            ? _buildSearchField()
            : const Text('Pianos', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: AppTheme.textPrimary),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<PianoListBloc>().add(const SearchPianos(''));
                }
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<PianoListBloc, PianoListState>(
        builder: (context, state) {
          if (state is PianoListLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
          }

          if (state is PianoListError) {
            return _buildErrorView(context, state.message);
          }

          if (state is PianoListLoaded) {
            return _buildLoadedView(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
      decoration: const InputDecoration(
        hintText: 'Tìm kiếm piano...',
        hintStyle: TextStyle(color: AppTheme.textSecondary),
        border: InputBorder.none,
      ),
      onChanged: (query) {
        context.read<PianoListBloc>().add(SearchPianos(query));
      },
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<PianoListBloc>().add(LoadPianos()),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedView(BuildContext context, PianoListLoaded state) {
    return Column(
      children: [
        // Category filter chips
        if (state.categories.isNotEmpty)
          Container(
            color: AppTheme.cardWhite,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip(context, 'Tất cả', null, state.activeCategory == null),
                  ...state.categories.map((cat) =>
                      _buildCategoryChip(context, cat, cat, state.activeCategory == cat)),
                ],
              ),
            ),
          ),

        // Grid danh sách đàn
        Expanded(
          child: state.pianos.isEmpty
              ? _buildEmptyView()
              : RefreshIndicator(
                  color: AppTheme.primaryGold,
                  onRefresh: () async {
                    context.read<PianoListBloc>().add(LoadPianos());
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.74, // Tăng aspect ratio để giảm chiều cao thẻ
                    ),
                    itemCount: state.pianos.length,
                    itemBuilder: (context, index) {
                      final piano = state.pianos[index];
                      return PianoCardWidget(
                        piano: piano,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PianoDetailScreen(pianoId: piano.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label, String? category, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => context.read<PianoListBloc>().add(FilterByCategory(category)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryGold : AppTheme.bgCream,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isActive ? AppTheme.primaryGold : AppTheme.dividerColor),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.piano_off, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 12),
          const Text('Không tìm thấy đàn piano', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}
