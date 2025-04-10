abstract class InstallmentEvent {}

class GetInstallmentsEvent extends InstallmentEvent {
  final String
  categoryId; // Qaysi kategoriya uchun nasiya to'lovlarini olish kerak

  GetInstallmentsEvent({required this.categoryId});
}
