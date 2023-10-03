// return a formatted data asa string
import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(Timestamp timestamp) {
  // timestamp is the object we retrieve from a firebase
  // to display it we convert it to a text String
  DateTime dateTime = timestamp.toDate();

  // get year
  String year = dateTime.year.toString();

  // get month
  String month = dateTime.month.toString();

  // get day
  String day = dateTime.day.toString();

  // final formatted date
  String formattedDate = '$day/$month /$year';
  return formattedDate;
}
