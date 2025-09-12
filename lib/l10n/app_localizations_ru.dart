// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get home => 'Главная';

  @override
  String get sessions => 'Сессии';

  @override
  String get community => 'Сообщество';

  @override
  String get profile => 'Профиль';

  @override
  String get goodMorning => 'Доброе утро,';

  @override
  String get goodNoon => 'Добрый полдень,';

  @override
  String get goodAfternoon => 'Добрый день,';

  @override
  String get goodEvening => 'Добрый вечер,';

  @override
  String get howAreYouFeeling => 'Как вы себя чувствуете сегодня?';

  @override
  String get planExpired => 'План истек';

  @override
  String get buyMore => 'Купить еще';

  @override
  String get planExamined => 'План проверен';

  @override
  String get viewDetails => 'Посмотреть детали';

  @override
  String get wellnessHub => 'Центр здоровья';

  @override
  String get trending => 'В тренде';

  @override
  String get relationship => 'Отношения';

  @override
  String get selfCare => 'Уход за собой';

  @override
  String get mentalHealth => 'Психическое здоровье';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get save => 'Сохранить';

  @override
  String get name => 'Имя';

  @override
  String get department => 'Отдел';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get email => 'Эл. почта';

  @override
  String get language => 'Язык';

  @override
  String get upcomingSession => 'Предстоящая сессия';

  @override
  String get joinNow => 'Присоединиться';

  @override
  String get allSessions => 'Все сессии';

  @override
  String get reschedule => 'Перенести';

  @override
  String get rebook => 'Забронировать снова';

  @override
  String get viewProfile => 'Посмотреть профиль';

  @override
  String userName(String userName) {
    return '$userName!';
  }
}
