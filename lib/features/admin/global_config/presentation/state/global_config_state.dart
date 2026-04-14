import 'package:fe_gangsta_flutter/features/admin/global_config/domain/entities/global_config_entity.dart';

class GlobalConfigState {
  const GlobalConfigState({
    this.config,
    this.isLoading = false,
    this.isSaving = false,
  });

  final GlobalConfigEntity? config;
  final bool isLoading;
  final bool isSaving;

  GlobalConfigState copyWith({
    GlobalConfigEntity? config,
    bool? isLoading,
    bool? isSaving,
  }) {
    return GlobalConfigState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
