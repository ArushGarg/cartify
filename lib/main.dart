import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/observers/app_bloc_observer.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/cart/cubit/cart_cubit.dart';
import 'features/orders/cubit/orders_cubit.dart';
import 'features/products/bloc/search_bloc.dart';
import 'features/products/cubit/product_cubit.dart';
import 'features/wishlist/cubit/wishlist_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  setupDependencies();

  runApp(const CartifyApp());
}

class CartifyApp extends StatelessWidget {
  const CartifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()),
        BlocProvider(create: (_) => getIt<ProductCubit>()..load()),
        BlocProvider(create: (_) => getIt<SearchBloc>()),
        BlocProvider(create: (_) => getIt<CartCubit>()),
        BlocProvider(create: (_) => getIt<WishlistCubit>()),
        BlocProvider(create: (_) => getIt<OrdersCubit>()),
        // CheckoutBloc is NOT here: it is scoped to the checkout route
      ],
      child: MaterialApp(
        title: 'Cartify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}