abstract class InstallmentState {}

class InstallmentInitialState extends InstallmentState {}

class InstallmentLoadingState extends InstallmentState {}

class InstallmentLoadedState extends InstallmentState {
  final double installmentBalance;

  InstallmentLoadedState({required this.installmentBalance});
}

class InstallmentErrorState extends InstallmentState {
  final String message;

  InstallmentErrorState(this.message);
}
