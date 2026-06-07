import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'routes/app_router.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';

final lastErrorNotifier = ValueNotifier<String?>(null);

void _reportError(Object error, StackTrace stack) {
  final message = 'Tipo: ${error.runtimeType}\n'
      'Erro: $error\n'
      'Stack (topo):\n${stack.toString().split('\n').take(6).join('\n')}';
  debugPrint('ERRO CAPTURADO:\n$message');
  lastErrorNotifier.value = message;
}

void main() {
  FlutterError.onError = (details) {
    _reportError(details.exception, details.stack ?? StackTrace.current);
    FlutterError.presentError(details);
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await NotificationService().initialize();

    runApp(const ProviderScope(child: CuidarPlusApp()));
  }, _reportError);
}

class CuidarPlusApp extends ConsumerWidget {
  const CuidarPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Cuidar+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      builder: (context, child) => Stack(
        children: [
          if (child != null) child,
          const _ErrorBanner(),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: lastErrorNotifier,
      builder: (context, message, _) {
        if (message == null) return const SizedBox.shrink();
        return Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: SafeArea(
            child: Material(
              color: const Color(0xFFB71C1C),
              borderRadius: BorderRadius.circular(12),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SelectableText(
                        message,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => lastErrorNotifier.value = null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
