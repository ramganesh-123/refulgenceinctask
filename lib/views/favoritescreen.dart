import 'package:ecommerce_app/viewmodels/viewmodel/favoriteviewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_app/views/detailsscreen.dart';
import 'package:ecommerce_app/widgets/card.dart';

class FavouritesScreen extends ConsumerStatefulWidget {
  const FavouritesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends ConsumerState<FavouritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favouritesViewModelProvider.notifier).loadFavourites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favouritesViewModelProvider);
    final viewModel = ref.read(favouritesViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9D781C),
        title: const Text('Favourites'),
        elevation: 2,
      ),
      body: _buildBody(context, state, viewModel),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FavouritesState state,
    FavouritesViewModel viewModel,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.favourites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No favourites yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding products to your favourites!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.favourites.length,
      itemBuilder: (context, index) {
        final product = state.favourites[index];
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
              viewModel.loadFavourites();
            });
          },
          onFavouriteToggle: () {
            viewModel.removeFavourite(product);
          },
        );
      },
    );
  }
}
