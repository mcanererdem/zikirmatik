/// Paths to generated trophy PNGs (`assets/generated/trophies/`).
abstract final class TrophyAssets {
  static const String bronze = 'assets/generated/trophies/trophy_bronze.png';
  static const String silver = 'assets/generated/trophies/trophy_silver.png';
  static const String gold = 'assets/generated/trophies/trophy_gold.png';
  static const String diamond = 'assets/generated/trophies/trophy_diamond.png';
  static const String platinum = 'assets/generated/trophies/trophy_platinum.png';

  static String pathForCupId(String cupId) {
    switch (cupId) {
      case 'bronze_kupa':
        return bronze;
      case 'silver_kupa':
        return silver;
      case 'gold_kupa':
        return gold;
      case 'diamond_kupa':
        return diamond;
      case 'platinum_kupa':
        return platinum;
      default:
        return bronze;
    }
  }
}
