extension DateTimeFormatter on DateTime {
  String formatTime() {
    final now = DateTime.now();

    // Agar sana kecha bo'lsa
    if (now.difference(this).inDays == 1) {
      return "Вчера";
    }

    // Sana dd/MM/yyyy formatida bo'lsin
    return "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year";
  }
}
