import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../theme/app_theme.dart';

class AppWebViewScreen extends StatefulWidget {
  const AppWebViewScreen({super.key});

  @override
  State<AppWebViewScreen> createState() => _AppWebViewScreenState();
}

class _AppWebViewScreenState extends State<AppWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0.0;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentNavIndex = 0;

  static const String baseUrl = 'https://vahan-vyvastha.vercel.app';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF8FAFC))
      ..setUserAgent('Mozilla/5.0 (Linux; Android 14; Mobile) STKVahanApp/1.0')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100.0;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
              _updateNavIndexFromUrl(url);
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _updateNavIndexFromUrl(url);
            });
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame ?? true) {
              setState(() {
                _hasError = true;
                _errorMessage = error.description;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('$baseUrl/#book'));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  void _updateNavIndexFromUrl(String url) {
    if (url.contains('admin')) {
      _currentNavIndex = 2;
    } else if (url.contains('schedule')) {
      _currentNavIndex = 1;
    } else {
      _currentNavIndex = 0;
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    if (index == 0) {
      _controller.loadRequest(Uri.parse('$baseUrl/#book'));
    } else if (index == 1) {
      _controller.loadRequest(Uri.parse('$baseUrl/#schedule'));
    } else if (index == 2) {
      _controller.loadRequest(Uri.parse('$baseUrl/#admin'));
    }
  }

  Future<bool> _handlePopScope() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }

    if (!mounted) return true;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 24),
            SizedBox(width: 10),
            Text('STK Vahan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: const Text(
          'શું તમારે એપ બંધ કરવી છે?\nDo you want to exit STK Vahan?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ના (Cancel)', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('હા (Exit)', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _handlePopScope();
        if (shouldExit && mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              // Loading Progress Bar
              if (_isLoading && _loadingProgress < 1.0)
                LinearProgressIndicator(
                  value: _loadingProgress,
                  minHeight: 2.5,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),

              // Main WebView or Error view
              Expanded(
                child: _hasError
                    ? _buildErrorView()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await _controller.reload();
                        },
                        color: AppColors.primary,
                        child: WebViewWidget(controller: _controller),
                      ),
              ),
            ],
          ),
        ),

        // Bottom Navigation Bar for Instant 1-Touch Switching
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentNavIndex,
            onTap: _onBottomNavTapped,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: const Color(0xFF64748B),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz_rounded, size: 22),
                activeIcon: Icon(Icons.quiz_rounded, size: 24),
                label: 'Quiz Booking',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_rounded, size: 22),
                activeIcon: Icon(Icons.calendar_month_rounded, size: 24),
                label: 'Schedule',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings_rounded, size: 22),
                activeIcon: Icon(Icons.admin_panel_settings_rounded, size: 24),
                label: 'Admin Portal',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, size: 48, color: Colors.red.shade600),
            ),
            const SizedBox(height: 20),
            const Text(
              'ઈન્ટરનેટ કનેક્શન નથી\nNo Internet Connection',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage.isNotEmpty ? _errorMessage : 'કૃપા કરીને તમારું ઈન્ટરનેટ કનેક્શન તપાસો.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _controller.reload();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('ફરી પ્રયાસ કરો (Retry)', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
