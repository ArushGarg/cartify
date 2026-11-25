import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/cart/cubit/cart_cubit.dart';
import '../../features/orders/cubit/orders_cubit.dart';
import '../../features/orders/data/order_repository.dart';
import '../../features/payment/bloc/checkout_bloc.dart';
import '../../features/payment/data/payment_repository.dart';
import '../../features/payment/data/razorpay_service.dart';
import '../../features/products/bloc/search_bloc.dart';
import '../../features/products/cubit/product_cubit.dart';
import '../../features/products/data/product_repository.dart';
import '../../features/wishlist/cubit/wishlist_cubit.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // External
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // Repositories (one instance for the whole app)
  getIt.registerLazySingleton<AuthRepository>(
          () => AuthRepository(getIt<SupabaseClient>()));
  getIt.registerLazySingleton<ProductRepository>(
          () => ProductRepository(getIt<SupabaseClient>()));
  getIt.registerLazySingleton<OrderRepository>(
          () => OrderRepository(getIt<SupabaseClient>()));
  getIt.registerLazySingleton<PaymentRepository>(
          () => PaymentRepository(getIt<http.Client>()));

  // Blocs/Cubits are factories: BlocProvider creates AND closes them
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
  getIt.registerFactory<ProductCubit>(
          () => ProductCubit(getIt<ProductRepository>()));
  getIt.registerFactory<SearchBloc>(
          () => SearchBloc(getIt<ProductRepository>()));
  getIt.registerFactory<CartCubit>(() => CartCubit());
  getIt.registerFactory<WishlistCubit>(() => WishlistCubit());
  getIt.registerFactory<OrdersCubit>(
          () => OrdersCubit(getIt<OrderRepository>()));
  getIt.registerFactory<CheckoutBloc>(() => CheckoutBloc(
    payments: getIt<PaymentRepository>(),
    orders: getIt<OrderRepository>(),
    razorpay: RazorpayService(),
  ));
}