import 'package:file_picker/file_picker.dart';
import 'package:tahweela/data/models/public_users.dart';

class ReferralDraft {
  final PublicUserModel patient;
  final String phone;
  final String diseaseType;
  final List<PlatformFile> files;

  const ReferralDraft({
    required this.patient,
    required this.phone,
    required this.diseaseType,
    required this.files,
  });
}
