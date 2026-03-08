import 'package:flutter/material.dart';

class DialogManager {
  static bool _isDialogOpen = false;
  static OverlayEntry? _overlayEntry;
  static DateTime? _dialogOpenTime;
  static const Duration _dialogTimeout = Duration(seconds: 30);
  
  // Dialog açma kontrolü
  static bool canShowDialog() {
    // Eğer dialog çok uzun süredir açıksa, durumunu sıfırla
    if (_isDialogOpen && _dialogOpenTime != null) {
      final elapsed = DateTime.now().difference(_dialogOpenTime!);
      if (elapsed > _dialogTimeout) {
        resetDialogState();
      }
    }
    return !_isDialogOpen;
  }
  
  // Dialog açıldığında çağrılır
  static void onDialogOpened() {
    _isDialogOpen = true;
    _dialogOpenTime = DateTime.now();
  }
  
  // Dialog kapandığında çağrılır
  static void onDialogClosed() {
    _isDialogOpen = false;
    _dialogOpenTime = null;
  }
  
  // Dialog durumunu manuel olarak sıfırla (hata durumları için)
  static void resetDialogState() {
    _isDialogOpen = false;
    _dialogOpenTime = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  
  // Snackbar gösterme kontrolü
  static bool _isSnackbarOpen = false;
  static DateTime? _snackbarOpenTime;
  static const Duration _snackbarTimeout = Duration(seconds: 10);
  
  static bool canShowSnackbar() {
    // Eğer snackbar çok uzun süredir açıksa, durumunu sıfırla
    if (_isSnackbarOpen && _snackbarOpenTime != null) {
      final elapsed = DateTime.now().difference(_snackbarOpenTime!);
      if (elapsed > _snackbarTimeout) {
        resetSnackbarState();
      }
    }
    return !_isSnackbarOpen;
  }
  
  static void onSnackbarShown() {
    _isSnackbarOpen = true;
    _snackbarOpenTime = DateTime.now();
  }
  
  static void onSnackbarHidden() {
    _isSnackbarOpen = false;
    _snackbarOpenTime = null;
  }
  
  // Snackbar durumunu manuel olarak sıfırla (hata durumları için)
  static void resetSnackbarState() {
    _isSnackbarOpen = false;
    _snackbarOpenTime = null;
  }
  
  // Tüm durumları sıfırla
  static void resetAllStates() {
    resetDialogState();
    resetSnackbarState();
  }
  
  // Overlay ile özel dialog kontrolü
  static void showCustomDialog({
    required BuildContext context,
    required Widget dialog,
    VoidCallback? onDismissed,
  }) {
    if (_isDialogOpen) return;
    
    onDialogOpened();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => DialogOverlay(
        dialog: dialog,
        onDismissed: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
          onDialogClosed();
          onDismissed?.call();
        },
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }
  
  // Tüm dialogları kapat
  static void closeAllDialogs() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    onDialogClosed();
  }
}

class DialogOverlay extends StatelessWidget {
  final Widget dialog;
  final VoidCallback onDismissed;
  
  const DialogOverlay({
    super.key,
    required this.dialog,
    required this.onDismissed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: onDismissed,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Dialog içine tıklamayı engelle
            child: dialog,
          ),
        ),
      ),
    );
  }
}
