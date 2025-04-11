import 'package:flutter/material.dart';

class AppGlobals {
  //!home--------------------------------------------------------
  //date--------------------
  static ValueNotifier<DateTime?> startDate = ValueNotifier<DateTime?>(null);
  static ValueNotifier<DateTime?> endDate = ValueNotifier<DateTime?>(null);

  //!cashflow ---------------------------------------------------
  //date--------------------
  static ValueNotifier<DateTime?> cashFlowStartDate = ValueNotifier<DateTime?>(
    null,
  );
  static ValueNotifier<DateTime?> cashFlowEndDate = ValueNotifier<DateTime?>(
    null,
  );

  //balance ----------------
  static ValueNotifier<bool?> cashFlowIsIncludeIncome = ValueNotifier<bool>(
    true,
  );
  static ValueNotifier<bool?> cashFlowIsIncludeExpence = ValueNotifier<bool>(
    true,
  );
  static ValueNotifier<bool?> cashFlowIsIncludeInstallment =
      ValueNotifier<bool>(true);

  //!archive------------------------------------------------------
  static ValueNotifier<DateTime?> archiveStartDate = ValueNotifier<DateTime?>(
    null,
  );
  static ValueNotifier<DateTime?> archiveEndDate = ValueNotifier<DateTime?>(
    null,
  );

  //!result-------------------------------------------------------
  //date ---------------------
  static ValueNotifier<DateTime?> resultStartDate = ValueNotifier<DateTime?>(
    null,
  );
  static ValueNotifier<DateTime?> resultEndDate = ValueNotifier<DateTime?>(
    null,
  );

  //balance ------------------
  static ValueNotifier<bool?> resultIsIncludeIncome = ValueNotifier<bool>(true);
  static ValueNotifier<bool?> resultIsIncludeExpence = ValueNotifier<bool>(
    true,
  );
  static ValueNotifier<bool?> resultIsIncludeInstallment = ValueNotifier<bool>(
    true,
  );

  //!reports------------------------------------------------------
  static ValueNotifier<DateTime?> expenseIncomeStartDate =
      ValueNotifier<DateTime?>(null);
  static ValueNotifier<DateTime?> expenseIncomeEndDate =
      ValueNotifier<DateTime?>(null);
}
