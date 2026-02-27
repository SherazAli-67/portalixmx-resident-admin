import 'package:flutter/cupertino.dart';

class LocaledProvider extends ChangeNotifier{
  Locale _locale = const Locale('en');

  Locale get getLocale => _locale;

  void setLocale(Locale locale){
    _locale = locale;
    notifyListeners();
  }

  bool get isSpanish{
    return _locale.languageCode == 'es';
  }
}