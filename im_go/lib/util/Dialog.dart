import 'package:awesome_dialog/awesome_dialog.dart';

void showAlertDialog(context, {desc}) {
  AwesomeDialog(
          context: context,
          dialogType: DialogType.WARNING,
          animType: AnimType.BOTTOMSLIDE,
          tittle: '警告',
          desc: desc,)
      .show();
}

void showInfoDialog(context, {desc}) {
  AwesomeDialog(
          context: context,
          dialogType: DialogType.INFO,
          animType: AnimType.BOTTOMSLIDE,
          tittle: '信息',
          desc: desc,)
      .show();
}
