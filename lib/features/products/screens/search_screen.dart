import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';
import '../bloc/search_bloc.dart';
import 'product_detail_screen.dart';

const _navy = Color(0xFF0F1729);
const _card = Color(0xFF1A2540);

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _suggestions = ['Shoes', 'Watch', 'Jeans', 'Bag', 'Hoodie'];
  final _controller = TextEditingController();

  void _search(String query) =>
      context.read<SearchBloc>().add(SearchQueryChanged(query));

  void _clear() {
    _controller.clear();
    context.read<SearchBloc>().add(const SearchCleared());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Search',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _controller,
                onChanged: _search, // debounced inside the Bloc
                textInputAction: TextInputAction.search,
                style: const TextStyle(color: Colors.white),
                cursorColor: AppTheme.primary,
                decoration: InputDecoration(
                  hintText: 'Search for clothes, shoes...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: _card,
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (_, value, __) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: _clear,
                    ),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                      const BorderSide(color: AppTheme.primary, width: 1.5)),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  switch (state.status) {
                    case SearchStatus.idle:
                      return _idle();
                    case SearchStatus.failure:
                      return _message(Icons.wifi_off_rounded,
                          state.error ?? 'Search failed.');
                    case SearchStatus.loading:
                      if (state.results.isEmpty) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primary));
                      }
                      return _grid(state, showProgress: true);
                    case SearchStatus.success:
                      if (state.results.isEmpty) {
                        return _message(Icons.search_off_rounded,
                            'No results for “${state.query}”');
                      }
                      return _grid(state);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _idle() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trending searches',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final s in _suggestions)
              GestureDetector(
                onTap: () {
                  _controller.text = s;
                  _search(s);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(s,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _message(IconData icon, String text) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 56, color: Colors.white24),
        const SizedBox(height: 12),
        Text(text, style: const TextStyle(color: Colors.white54)),
      ],
    ),
  );

  Widget _grid(SearchState state, {bool showProgress = false}) => Column(
    children: [
      if (showProgress)
        const LinearProgressIndicator(
            minHeight: 2, color: AppTheme.primary, backgroundColor: _card),
      Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.60,
            crossAxisSpacing: 14,
            mainAxisSpacing: 18,
          ),
          itemCount: state.results.length,
          itemBuilder: (context, i) {
            final product = state.results[i];
            return ProductCard(
              product: product,
              onOpen: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product)),
              ),
            );
          },
        ),
      ),
    ],
  );
}