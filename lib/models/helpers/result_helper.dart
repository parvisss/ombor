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
    bool? isIncomeIncluded,
    bool? isExpenceIncluded,
    bool? isInstallmentIncluded,
  }) async {
    return _filterCashFlows(
      cashFlows: allCashFlows,
      fromDate: fromDate,
      toDate: toDate,
      isExpenceIncluded: isExpenceIncluded,
      isIncomeIncluded: isIncomeIncluded,
      isInstallmentIncluded: isInstallmentIncluded,
    );
  }

  //! Faqat chiqim ma'lumotlarini olish
  Future<List<CashFlowModel>> getExpenseCashFlows({
    required List<CashFlowModel> allCashFlows,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final filteredByDate = _filterCashFlows(
      cashFlows: allCashFlows,
      fromDate: fromDate,
      toDate: toDate,
    );
    return filteredByDate.where((flow) => flow.isPositive == 0).toList();
  }

  //! Faqat kirim ma'lumotlarini olish
  Future<List<CashFlowModel>> getIncomeCashFlows({
    required List<CashFlowModel> allCashFlows,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final filteredByDate = _filterCashFlows(
      cashFlows: allCashFlows,
      fromDate: fromDate,
      toDate: toDate,
    );

    return filteredByDate.where((flow) => flow.isPositive == 1).toList();
  }

  List<CashFlowModel> _filterCashFlows({
    required List<CashFlowModel> cashFlows,
    DateTime? fromDate,
    DateTime? toDate,
    bool? isIncomeIncluded,
    bool? isExpenceIncluded,
    bool? isInstallmentIncluded,
  }) {
    return cashFlows.where((flow) {
      DateTime? flowTime;
      try {
        flowTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(flow.time);
      } catch (e) {
        try {
          flowTime = DateFormat('yyyy-MM-dd').parse(flow.time);
        } catch (e) {
          try {
            flowTime = DateFormat('dd/MM/yyyy').parse(flow.time);
          } catch (e) {
            return false;
          }
        }
      }

      final isAfterOrEqual =
          fromDate == null ||
          flowTime.isAfter(fromDate) ||
          flowTime.isAtSameMomentAs(fromDate);
      final isBeforeOrEqual =
          toDate == null ||
          flowTime.isBefore(toDate) ||
          flowTime.isAtSameMomentAs(toDate);

      // Tip bo‘yicha filtering (faqat belgilanganlari o‘tadi)
      bool typeMatches = false;

      if (isIncomeIncluded == true && flow.isPositive == 1) {
        typeMatches = true;
      }
      if (isExpenceIncluded == true &&
          flow.isPositive == 0 &&
          flow.isInstallment == 0) {
        typeMatches = true;
      }
      if (isInstallmentIncluded == true &&
          flow.isPositive == 0 &&
          flow.isInstallment == 1) {
        typeMatches = true;
      }

      // Agar hech biri tanlanmagan bo‘lsa, hammasini chiqar
      if (isIncomeIncluded == null &&
          isExpenceIncluded == null &&
          isInstallmentIncluded == null) {
        typeMatches = true;
      }

      return isAfterOrEqual && isBeforeOrEqual && typeMatches;
    }).toList();
  }
}
