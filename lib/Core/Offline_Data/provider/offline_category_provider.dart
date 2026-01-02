import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../offline_db/offline_category_db.dart';

final offlineCategoryDbProvider = Provider<OfflineCategoryDb>((ref) {
  return OfflineCategoryDb();
});
