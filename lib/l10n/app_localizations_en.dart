// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get sessions => 'Sessions';

  @override
  String get community => 'Community';

  @override
  String get profile => 'Profile';

  @override
  String get goodMorning => 'Good Morning,';

  @override
  String get goodNoon => 'Good Noon,';

  @override
  String get goodAfternoon => 'Good Afternoon,';

  @override
  String get goodEvening => 'Good Evening,';

  @override
  String get howAreYouFeeling => 'How are you feeling today ?';

  @override
  String get planExpired => 'Plan Expired';

  @override
  String get buyMore => 'Buy More';

  @override
  String get planExamined => 'Plan Examined';

  @override
  String get viewDetails => 'View Details';

  @override
  String get wellnessHub => 'Wellness Hub';

  @override
  String get trending => 'Trending';

  @override
  String get relationship => 'Relationship';

  @override
  String get selfCare => 'Self Care';

  @override
  String get mentalHealth => 'Mental Health';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get save => 'Save';

  @override
  String get name => 'Name';

  @override
  String get department => 'Department';

  @override
  String get phoneNumber => 'Phone no.';

  @override
  String get email => 'E-Mail';

  @override
  String get language => 'Language';

  @override
  String get upcomingSession => 'Upcoming Session';

  @override
  String get joinNow => 'Join Now';

  @override
  String get allSessions => 'All Sessions';

  @override
  String get reschedule => 'Reschedule';

  @override
  String get rebook => 'Re-book';

  @override
  String get viewProfile => 'View Profile';

  @override
  String userName(String userName) {
    return '$userName!';
  }
}
