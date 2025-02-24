import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';

Widget customTextField({
  required TextEditingController controller,
  required String hintText,
}) {
  return TextBox(
    controller: controller,
    placeholder: hintText,
    style: GoogleFonts.inter(),
  );
}
