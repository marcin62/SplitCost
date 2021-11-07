
String validateMobile(String value) {
  String patttern = r'(^(?:[+0]9)?[0-9]{9,9}$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
        return 'Wprowadź numer telefonu';
  }
  else if (!regExp.hasMatch(value)) {
        return 'Prawidłowy numer zawiera 9 cyfr';
  }
  return null;
}  
