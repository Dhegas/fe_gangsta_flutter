class TenantCreateState {
  const TenantCreateState({this.isSubmitting = false, this.errorMessage});

  final bool isSubmitting;
  final String? errorMessage;

  static const _noChange = Object();

  TenantCreateState copyWith({
    bool? isSubmitting,
    Object? errorMessage = _noChange,
  }) {
    return TenantCreateState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage == _noChange
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
