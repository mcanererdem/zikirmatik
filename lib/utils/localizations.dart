class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static final Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      'app_name': 'Zikirmatik',
      'counter': 'Sayaç',
      'target': 'Hedef',
      'reset': 'Sıfırla',
      'continue': 'Devam Et',
      'cancel': 'İptal',
      'ok': 'Tamam',
      'settings': 'Ayarlar',
      'theme': 'Tema',
      'language': 'Dil',
      'vibration': 'Titreşim',
      'sound': 'Ses',
      'select_zikr': 'Zikir Seç',
      'add_zikr': 'Zikir Ekle',
      'custom_zikrs': 'Özel Zikirler',
      'zikr_name_ar': 'Arapça İsim',
      'zikr_name_tr': 'Türkçe İsim',
      'zikr_name_en': 'İngilizce İsim',
      'default_count': 'Varsayılan Adet',
      'set_target': 'Hedef Belirle',
      'quick_select': 'Hızlı Seçim',
      'custom_target': 'Özel Hedef',
      'enter_target': 'Hedef sayısını girin',
      'success_title': 'Maşallah! 🎉',
      'success_message': 'Hedefinize ulaştınız!',
      'zikr_count': 'Zikir',
      'edit': 'Düzenle',
      'delete': 'Sil',
      'save': 'Kaydet',
      'arabic': 'العربية',
      'turkish': 'Türkçe',
      'english': 'English',
      'incrementCounter': 'Increment counter',
      'resetCounter': 'Reset counter',
      'changeTarget': 'Change target',
      'vibrationOn': 'Vibration on',
      'vibrationOff': 'Vibration off',
      'soundOn': 'Sound on',
      'soundOff': 'Sound off',
      'about': 'Hakkında',
    },
    'en': {
      'app_name': 'Tasbih Counter',
      'counter': 'Counter',
      'target': 'Target',
      'reset': 'Reset',
      'continue': 'Continue',
      'cancel': 'Cancel',
      'ok': 'OK',
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'vibration': 'Vibration',
      'sound': 'Sound',
      'select_zikr': 'Select Dhikr',
      'add_zikr': 'Add Dhikr',
      'custom_zikrs': 'Custom Dhikrs',
      'zikr_name_ar': 'Arabic Name',
      'zikr_name_tr': 'Turkish Name',
      'zikr_name_en': 'English Name',
      'default_count': 'Default Count',
      'set_target': 'Set Target',
      'quick_select': 'Quick Select',
      'custom_target': 'Custom Target',
      'enter_target': 'Enter target number',
      'success_title': 'MashaAllah! 🎉',
      'success_message': 'Target reached!',
      'zikr_count': 'Dhikr',
      'edit': 'Edit',
      'delete': 'Delete',
      'save': 'Save',
      'arabic': 'العربية',
      'turkish': 'Türkçe',
      'english': 'English',
      'incrementCounter': 'Increment counter',
      'resetCounter': 'Reset counter',
      'changeTarget': 'Change target',
      'vibrationOn': 'Vibration on',
      'vibrationOff': 'Vibration off',
      'soundOn': 'Sound on',
      'soundOff': 'Sound off',
      'about': 'About',
    },
    'ar': {
      'app_name': 'مسبحة إلكترونية',
      'counter': 'العداد',
      'target': 'الهدف',
      'reset': 'إعادة تعيين',
      'continue': 'متابعة',
      'cancel': 'إلغاء',
      'ok': 'موافق',
      'settings': 'الإعدادات',
      'theme': 'المظهر',
      'language': 'اللغة',
      'vibration': 'الاهتزاز',
      'sound': 'الصوت',
      'select_zikr': 'اختر الذكر',
      'add_zikr': 'إضافة ذكر',
      'custom_zikrs': 'أذكار مخصصة',
      'zikr_name_ar': 'الاسم بالعربية',
      'zikr_name_tr': 'الاسم بالتركية',
      'zikr_name_en': 'الاسم بالإنجليزية',
      'default_count': 'العدد الافتراضي',
      'set_target': 'تحديد الهدف',
      'quick_select': 'اختيار سريع',
      'custom_target': 'هدف مخصص',
      'enter_target': 'أدخل رقم الهدف',
      'success_title': 'ماشاء الله! 🎉',
      'success_message': 'تم الوصول إلى الهدف!',
      'zikr_count': 'ذكر',
      'edit': 'تعديل',
      'delete': 'حذف',
      'save': 'حفظ',
      'arabic': 'العربية',
      'turkish': 'Türkçe',
      'english': 'English',
      'incrementCounter': 'زيادة العداد',
      'resetCounter': 'إعادة ضبط العداد',
      'changeTarget': 'تغيير الهدف',
      'vibrationOn': 'الاهتزاز قيد التشغيل',
      'vibrationOff': 'الاهتزاز متوقف',
      'soundOn': 'الصوت قيد التشغيل',
      'soundOff': 'الصوت مغلق',
      'about': 'حول',
    },
  };

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ?? key;
  }

  String get appName => translate('app_name');
  String get counter => translate('counter');
  String get target => translate('target');
  String get reset => translate('reset');
  String get continueText => translate('continue');
  String get cancel => translate('cancel');
  String get ok => translate('ok');
  String get settings => translate('settings');
  String get theme => translate('theme');
  String get language => translate('language');
  String get vibration => translate('vibration');
  String get sound => translate('sound');
  String get selectZikr => translate('select_zikr');
  String get addZikr => translate('add_zikr');
  String get customZikrs => translate('custom_zikrs');
  String get zikrNameAr => translate('zikr_name_ar');
  String get zikrNameTr => translate('zikr_name_tr');
  String get zikrNameEn => translate('zikr_name_en');
  String get defaultCount => translate('default_count');
  String get setTarget => translate('set_target');
  String get quickSelect => translate('quick_select');
  String get customTarget => translate('custom_target');
  String get enterTarget => translate('enter_target');
  String get successTitle => translate('success_title');
  String get successMessage => translate('success_message');
  String get zikrCount => translate('zikr_count');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get save => translate('save');
  String get arabic => translate('arabic');
  String get turkish => translate('turkish');
  String get english => translate('english');
  String get incrementCounter => translate('incrementCounter');
  String get resetCounter => translate('resetCounter');
  String get changeTarget => translate('changeTarget');
  String get vibrationOn => translate('vibrationOn');
  String get vibrationOff => translate('vibrationOff');
  String get soundOn => translate('soundOn');
  String get soundOff => translate('soundOff');
  String get about => translate('about');
}