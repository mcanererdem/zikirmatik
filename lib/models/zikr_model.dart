class ZikrModel {
  final String id;
  final String nameAr;
  final String nameTr;
  final String nameEn;
  final int defaultCount;
  final bool isCustom;
  final bool isEditable;

  ZikrModel({
    required this.id,
    required this.nameAr,
    required this.nameTr,
    required this.nameEn,
    required this.defaultCount,
    this.isCustom = false,
    this.isEditable = false,
  });

  ZikrModel copyWith({
    String? id,
    String? nameAr,
    String? nameTr,
    String? nameEn,
    int? defaultCount,
    bool? isCustom,
    bool? isEditable,
  }) {
    return ZikrModel(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameTr: nameTr ?? this.nameTr,
      nameEn: nameEn ?? this.nameEn,
      defaultCount: defaultCount ?? this.defaultCount,
      isCustom: isCustom ?? this.isCustom,
      isEditable: isEditable ?? this.isEditable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameTr': nameTr,
      'nameEn': nameEn,
      'defaultCount': defaultCount,
    };
  }

  factory ZikrModel.fromJson(Map<String, dynamic> json) {
    return ZikrModel(
      id: json['id'],
      nameAr: json['nameAr'],
      nameTr: json['nameTr'],
      nameEn: json['nameEn'],
      defaultCount: json['defaultCount'],
    );
  }
}

class DefaultZikrs {
  static final List<ZikrModel> zikrs = [
    ZikrModel(
      id: '1',
      nameAr: 'سُبْحَانَ اللّٰهِ',
      nameTr: 'Sübhanallah',
      nameEn: 'Subhanallah',
      defaultCount: 33,
      isEditable: true,
    ),
    ZikrModel(
      id: '2',
      nameAr: 'اَلْحَمْدُ لِلّٰهِ',
      nameTr: 'Elhamdülillah',
      nameEn: 'Alhamdulillah',
      defaultCount: 33,
      isEditable: true,
    ),
    ZikrModel(
      id: '3',
      nameAr: 'اَللّٰهُ اَكْبَرُ',
      nameTr: 'Allahu Ekber',
      nameEn: 'Allahu Akbar',
      defaultCount: 33,
      isEditable: true,
    ),
    ZikrModel(
      id: '4',
      nameAr: 'لَا إِلٰهَ إِلَّا اللّٰهُ',
      nameTr: 'La ilahe illallah',
      nameEn: 'La ilaha illallah',
      defaultCount: 100,
      isEditable: true,
    ),
    ZikrModel(
      id: '5',
      nameAr: 'اَسْتَغْفِرُ اللّٰهَ',
      nameTr: 'Estağfirullah',
      nameEn: 'Astaghfirullah',
      defaultCount: 100,
      isEditable: true,
    ),
    ZikrModel(
      id: '6',
      nameAr: 'صَلَّى اللّٰهُ عَلَيْهِ وَسَلَّمَ',
      nameTr: 'Salat-ı Şerif',
      nameEn: 'Salawat',
      defaultCount: 100,
      isEditable: true,
    ),
  ];
}