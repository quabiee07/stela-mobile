import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/models/generic_model.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/profile/domain/models/daily_reminder_payload.dart';
import 'package:stela_mobile/features/profile/domain/repository/profile_repository.dart';

class SetReminderUseCase implements UseCase<GenericModel, DailyReminderPayload>{
  late final ProfileRepository profileRepository;
  late final DailyReminderPayload payload;
  SetReminderUseCase(this.profileRepository, this.payload);

  @override
  Future<ApiResult<GenericModel>> invoke() {
    return profileRepository.setReminder(payload);
  }
  
  @override
  DailyReminderPayload get param => payload;
  
}