import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductRepository {
  ProductRepository(this._client);
  final SupabaseClient _client;

  Future<List<Product>> fetchProducts() async {
    final response = await _client
        .from('products')
        .select()
        .order('created_at', ascending: false)
        .timeout(const Duration(seconds: 15));
    return _parse(response);
  }

  /// Server-side search (ilike on name + category)
  Future<List<Product>> search(String query) async {
    // Strip characters that would break PostgREST's or() filter syntax
    final q = query.replaceAll(RegExp(r'[,()%*]'), ' ').trim();
    if (q.isEmpty) return [];
    final response = await _client
        .from('products')
        .select()
        .or('name.ilike.%$q%,category.ilike.%$q%')
        .limit(30)
        .timeout(const Duration(seconds: 15));
    return _parse(response);
  }

  List<Product> _parse(dynamic response) => (response as List)
      .map((j) => Product.fromJson(Map<String, dynamic>.from(j as Map)))
      .toList();
}