import 'package:ecommerce_app/viewmodels/viewmodel/detailsviewmodel.dart';
import 'package:ecommerce_app/widgets/dialogue.dart';
import 'package:ecommerce_app/widgets/review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailViewModelProvider(productId));
    final viewModel =
        ref.read(productDetailViewModelProvider(productId).notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9D781C),
        title: const Text('Product Details'),
        elevation: 2,
        actions: [
          if (state.product != null)
            IconButton(
              icon: Icon(
                state.product!.isFavourite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: state.product!.isFavourite ? Colors.red : null,
              ),
              onPressed: () {
                viewModel.toggleFavourite();
              },
            ),
        ],
      ),
      body: _buildBody(context, state, viewModel),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProductDetailState state,
    ProductDetailViewModel viewModel,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
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
              onPressed: () => viewModel.loadProductDetails(productId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.product == null) {
      return const Center(
        child: Text('Product not found'),
      );
    }

    final product = state.product!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'product_${product.id}',
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 300,
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 300,
                color: Colors.grey[300],
                child: const Icon(Icons.error, size: 64),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Seller: ${product.sellerName ?? "Unknown"}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.body,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reviews (${state.reviews.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddReviewDialog(
                            onSubmit: (name, email, body) {
                              viewModel.addLocalReview(name, email, body);
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Review'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.reviews.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No reviews yet'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.reviews.length,
                    itemBuilder: (context, index) {
                      return ReviewCard(review: state.reviews[index]);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
