import 'package:flutter/material.dart';

class DialogManager {
  static bool _canShowSnackbar = true;
  static bool _canShowDialog = true;

  static bool canShowSnackbar() => _canShowSnackbar;
  static bool canShowDialog() => _canShowDialog;

  static void onSnackbarShown() => _canShowSnackbar = false;
  static void onSnackbarHidden() => _canShowSnackbar = true;
  static void onDialogOpened() => _canShowDialog = false;
  static void onDialogClosed() => _canShowDialog = true;

  static void resetAllStates() {
    _canShowSnackbar = true;
    _canShowDialog = true;
  }
}
