import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../injection_container.dart';

class AppBlocObserver extends BlocObserver {
  final Logger logger = sl<Logger>();

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    logger.i('Khoi tao Bloc: ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // logger.d('State thay doi: ${bloc.runtimeType} -> $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    logger.e('Loi xay ra trong Bloc: ${bloc.runtimeType}', error: error, stackTrace: stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    logger.i('Dong Bloc: ${bloc.runtimeType}');
  }
}
