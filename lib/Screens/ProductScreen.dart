import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../Api/ApiResponse.dart';
import '../Controller/ProductController.dart';
import '../Modal/Product.dart';

class ProductScreen extends StatelessWidget {
  ProductScreen({super.key});

  final ProductController controller = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: Obx(() {
        final state = controller.apiResponse.value;

        if (state is Loading<List<Product>>) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is Success<List<Product>>) {
          final products = state.data;
          // Handle empty state explicitly
          if (products.isEmpty) {
            return const Center(child: Text("No products found."));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8.0), // Add padding to the grid itself
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0, // Space between columns
              mainAxisSpacing: 10.0,  // Space between rows
              childAspectRatio: 0.75, // Adjust this to control card height relative to width
              //  1.0 for square, <1 for taller, >1 for wider
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                clipBehavior: Clip.antiAlias, // Ensures content respects card border radius
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
                  children: [
                    Expanded( // Image takes available space within its column
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)), // Only top corners rounded
                        child: (product.images != null && product.images!.isNotEmpty)
                            ? Image.network(
                          product.images![0],
                          fit: BoxFit.cover, // Use cover to fill the space without distorting
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                            );
                          },
                        )
                            : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                        ), // Placeholder for missing image URL
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0), // Padding around text
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title ?? 'No Title', // Handle null title
                            maxLines: 2, // Limit title to 2 lines
                            overflow: TextOverflow.ellipsis, // Add ellipsis if title is too long
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          // You can add more product details here, like price, rating, etc.
                          // if (product.price != null)
                          //   Text('\$${product.price!.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.green)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else if (state is Failure<List<Product>>) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => controller.fetchProducts(), // Assuming you have a method to retry
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text("Tap to load products")); // Initial or unexpected state
        }
      }),
    );
  }
}
