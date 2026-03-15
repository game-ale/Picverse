import 'package:hive_flutter/hive_flutter.dart';

import 'package:picverse/core/local/hive_constants.dart';

/// Queues like / unlike operations while offline and replays them when
/// connectivity is restored.
///
/// Each entry is stored as a Map:
/// ```
/// { "action": "like" | "unlike", "postId": "...", "userId": "..." }
/// ```
class OfflineQueueService {
  Future<void> enqueue({
    required String action,
    required String postId,
    required String userId,
  }) async {
    final box = await Hive.openBox<Map>(HiveConstants.offlineQueueBox);
    await box.add({'action': action, 'postId': postId, 'userId': userId});
  }

  Future<List<Map<String, dynamic>>> drain() async {
    final box = await Hive.openBox<Map>(HiveConstants.offlineQueueBox);
    final items = box.values.map((e) => Map<String, dynamic>.from(e)).toList();
    await box.clear();
    return items;
  }

  Future<bool> get hasItems async {
    final box = await Hive.openBox<Map>(HiveConstants.offlineQueueBox);
    return box.isNotEmpty;
  }
}
