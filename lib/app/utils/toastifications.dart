import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

class CustomToasts {
  void showSuccessToast(String message, BuildContext context) {
    toastification.show(
      context: context,
      style: ToastificationStyle.fillColored,
      type: ToastificationType.success,
      autoCloseDuration: Duration(seconds: 5),
      applyBlurEffect: true,
      closeOnClick: true,
      dragToClose: true,
      pauseOnHover: true,
      showProgressBar: true,
      description: Text(message, style: GoogleFonts.inter()),
    );
  }

  void showWarningToast(String message, BuildContext context) {
    toastification.show(
      context: context,
      style: ToastificationStyle.fillColored,
      type: ToastificationType.warning,
      autoCloseDuration: Duration(seconds: 5),
      applyBlurEffect: true,
      closeOnClick: true,
      dragToClose: true,
      pauseOnHover: true,
      showProgressBar: true,
      description: Text(message, style: GoogleFonts.inter()),
    );
  }

  void showErrorToast(String message, BuildContext context) {
    toastification.show(
      context: context,
      style: ToastificationStyle.fillColored,
      type: ToastificationType.error,
      autoCloseDuration: Duration(seconds: 5),
      applyBlurEffect: true,
      closeOnClick: true,
      dragToClose: true,
      pauseOnHover: true,
      showProgressBar: true,
      description: Text(message, style: GoogleFonts.inter()),
    );
  }
}
