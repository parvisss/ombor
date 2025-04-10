import 'package:easy_localization/easy_localization.dart';
import 'package:ombor/models/cash_flow_model.dart';

class ResultHelper {
  static ResultHelper? _instance;

  ResultHelper._internal();

  factory ResultHelper() {
    return _instance ??= ResultHelper._internal();
  }

  //! Umumiy (kirim va chiqim) ma'lumotlarni olish
  Future<List<CashFlowModel>> getCombinedCashFlows({
    required List<CashFlowModel> allCashFlows,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return _filterCashFlowsByDate(allCashFlows, fromDate, toDate);
  }

  //! Faqat chiqim ma'lumotlarini olish
  Future<List<CashFlowModel>> getExpenseCashFlows({
    required List<CashFlowModel> allCashFlows,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final filteredByDate = _filterCashFlowsByDate(
      allCashFlows,
      fromDate,
      toDate,
    );
    return filteredByDate.where((flow) => flow.isPositive == 0).toList();
  }

  //! Faqat kirim ma'lumotlarini olish
  Future<List<CashFlowModel>> getIncomeCashFlows({
    required List<CashFlowModel> allCashFlows,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final filteredByDate = _filterCashFlowsByDate(
      allCashFlows,
      fromDate,
      toDate,
    );
    return filteredByDate.where((flow) => flow.isPositive == 1).toList();
  }

  //! Sanaga ko'ra filtrlash uchun yordamchi funksiya

  List<CashFlowModel> _filterCashFlowsByDate(
    List<CashFlowModel> cashFlows,
    DateTime? fromDate,
    DateTime? toDate,
  ) {
    return cashFlows.where((flow) {
      DateTime? flowTime;
      try {
        flowTime = DateFormat('dd/MM/yyyy').parse(flow.time);
      } catch (e) {
        print("Error parsing time: ${flow.time}. Error: $e");
        return false; // Agar formatlashda xatolik bo'lsa, bu elementni o'tkazib yuboramiz
      }

      final isAfterOrEqual =
          fromDate == null ||
          flowTime.isAfter(fromDate) ||
          flowTime.isAtSameMomentAs(fromDate);
      final isBeforeOrEqual =
          toDate == null ||
          flowTime.isBefore(toDate) ||
          flowTime.isAtSameMomentAs(toDate);
      return isAfterOrEqual && isBeforeOrEqual;
    }).toList();
  }
}
