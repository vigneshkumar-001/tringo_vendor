import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Api/DataSource/api_data_source.dart';
import '../../Presentation/Login Screen/Controller/login_notifier.dart';
import 'offline_sync_db.dart';
import 'offline_sync_engine.dart';

final offlineSyncDbProvider = Provider<OfflineSyncDb>((ref) => OfflineSyncDb());

final offlineSyncEngineProvider = Provider<OfflineSyncEngine>((ref) {
  final db = ref.read(offlineSyncDbProvider);
  final api = ref.read(apiDataSourceProvider);
  return OfflineSyncEngine(db: db, api: api);
});
