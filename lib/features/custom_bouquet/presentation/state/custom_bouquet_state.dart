import 'package:equatable/equatable.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/entities/custom_bouquet_entity.dart';

enum CustomBouquetStatus { idle, submitting, success, error }

class CustomBouquetState extends Equatable {
  final int step; // 1-5
  final CustomBouquetEntity bouquet;
  final CustomBouquetStatus status;
  final String? errorMessage;

  const CustomBouquetState({
    this.step = 1,
    this.bouquet = const CustomBouquetEntity(),
    this.status = CustomBouquetStatus.idle,
    this.errorMessage,
  });

  bool get canProceed {
    switch (step) {
      case 1:
        return bouquet.flowers.isNotEmpty;
      case 2:
        return bouquet.flowers.every((f) => f.count > 0);
      case 3:
        return bouquet.wrapping != null;
      case 4:
        return true;
      case 5:
        return true;
      default:
        return false;
    }
  }

  CustomBouquetState copyWith({
    int? step,
    CustomBouquetEntity? bouquet,
    CustomBouquetStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CustomBouquetState(
      step: step ?? this.step,
      bouquet: bouquet ?? this.bouquet,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [step, bouquet, status, errorMessage];
}
