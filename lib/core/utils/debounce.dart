import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

/// Waits for the user to stop typing, then cancels any in-flight handler
/// when a newer event arrives (debounce + switchMap).
EventTransformer<E> debounceRestartable<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}