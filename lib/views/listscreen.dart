import 'package:ecommerce_app/viewmodels/viewmodel/productviewmodel.dart';
import 'package:ecommerce_app/views/detailsscreen.dart';
import 'package:ecommerce_app/views/favoritescreen.dart';
import 'package:ecommerce_app/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(productListViewModelProvider.notifier)
          .loadProducts(refresh: true);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productListViewModelProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListViewModelProvider);
    final viewModel = ref.read(productListViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9D781C),
        title: const Text('Products'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavouritesScreen(),
                ),
              ).then((_) {
                viewModel.loadProducts(refresh: true);
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              viewModel.sortProducts(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'none',
                child: Text('Default'),
              ),
              const PopupMenuItem(
                value: 'title',
                child: Text('Sort by Title'),
              ),
              const PopupMenuItem(
                value: 'seller',
                child: Text('Sort by Seller'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          viewModel.searchProducts('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                viewModel.searchProducts(value);
              },
            ),
          ),
          Expanded(
            child: _buildBody(state, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ProductListState state, ProductListViewModel viewModel) {
    if (state.isLoading && state.products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null && state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadProducts(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.products.isEmpty) {
      return const Center(
        child: Text('No products found'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadProducts(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.products.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.products.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final product = state.products[index];
          return ProductCard(
            product: product,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    productId: product.id,
                  ),
                ),
              ).then((_) {
                viewModel.loadProducts(refresh: true);
              });
            },
            onFavouriteToggle: () {
              viewModel.toggleFavourite(product);
            },
          );
        },
      ),
    );
  }
}
