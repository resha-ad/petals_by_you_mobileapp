class HiveTableConstant {
  HiveTableConstant._();

  static const String dbName = 'petals_by_you_db';

  //Auth
  static const int authTypeId = 1;
  static const String authTable = 'auth_table';

  // Items
  // authTypeId = 1 is already taken, so items uses 2.
  static const int itemTypeId = 2;
  static const String itemTable = 'item_table';

  //potential future settings storage
  static const String appSettingsTable = 'app_settings';
}
