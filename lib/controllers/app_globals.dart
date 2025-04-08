import 'package:flutter/material.dart';

class AppGlobals {
  // ValueNotifier orqali sana oralig'ini saqlash
  static ValueNotifier<DateTime?> startDate = ValueNotifier<DateTime?>(null);
  static ValueNotifier<DateTime?> endDate = ValueNotifier<DateTime?>(null);

  //archive
  static ValueNotifier<DateTime?> archiveStartDate = ValueNotifier<DateTime?>(
    null,
  );
  static ValueNotifier<DateTime?> archiveEndDate = ValueNotifier<DateTime?>(
    null,
  );

  //result
  static ValueNotifier<DateTime?> resultStartDate = ValueNotifier<DateTime?>(
    null,
  );
  static ValueNotifier<DateTime?> resultEndDate = ValueNotifier<DateTime?>(
    null,
  );
}
