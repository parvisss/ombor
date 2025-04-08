abstract class BalanceState {}

class BalanceInitialState extends BalanceState {}

class BalanceLoadingState extends BalanceState {}

class BalanceLoadedState extends BalanceState {
  final double totalBalance;

  BalanceLoadedState(this.totalBalance);
}

class BalanceErrorState extends BalanceState {
  final String errorMessage;

  BalanceErrorState(this.errorMessage);
}
