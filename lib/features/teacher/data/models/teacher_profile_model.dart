import 'package:equatable/equatable.dart';

/// Entity chứa thông tin hồ sơ giáo viên (teacher_profiles table).
class TeacherProfile extends Equatable {
  final String id;
  final String userId;
  final String fullName;
  final String? bio;
  final List<String> specializations;
  final int yearsExperience;
  final bool teachOnline;
  final bool teachOffline;
  final List<String> locations;
  final int priceOnline;
  final int priceOffline;
  final int bundle8Sessions;
  final String bundle8Discount;
  final int bundle12Sessions;
  final String bundle12Discount;
  final bool allowTrialLesson;
  final String? idNumber;
  final String? idFrontUrl;
  final String? idBackUrl;
  final String? bankName;
  final String? bankAccount;
  final String? accountHolder;
  final String? certificatesDescription;
  final List<String> certificateUrls;
  final String? avatarUrl;
  final String? videoDemoUrl;
  final String verificationStatus; // 'pending' | 'approved' | 'rejected'
  final String? rejectedReason;

  const TeacherProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    this.bio,
    this.specializations = const [],
    this.yearsExperience = 0,
    this.teachOnline = false,
    this.teachOffline = false,
    this.locations = const [],
    this.priceOnline = 0,
    this.priceOffline = 0,
    this.bundle8Sessions = 8,
    this.bundle8Discount = '0',
    this.bundle12Sessions = 12,
    this.bundle12Discount = '0',
    this.allowTrialLesson = false,
    this.idNumber,
    this.idFrontUrl,
    this.idBackUrl,
    this.bankName,
    this.bankAccount,
    this.accountHolder,
    this.certificatesDescription,
    this.certificateUrls = const [],
    this.avatarUrl,
    this.videoDemoUrl,
    this.verificationStatus = 'pending',
    this.rejectedReason,
  });

  bool get isApproved => verificationStatus == 'approved';
  bool get isPending => verificationStatus == 'pending';
  bool get isRejected => verificationStatus == 'rejected';

  @override
  List<Object?> get props => [id, userId, verificationStatus];
}

class TeacherProfileModel extends TeacherProfile {
  const TeacherProfileModel({
    required super.id,
    required super.userId,
    required super.fullName,
    super.bio,
    super.specializations,
    super.yearsExperience,
    super.teachOnline,
    super.teachOffline,
    super.locations,
    super.priceOnline,
    super.priceOffline,
    super.bundle8Sessions,
    super.bundle8Discount,
    super.bundle12Sessions,
    super.bundle12Discount,
    super.allowTrialLesson,
    super.idNumber,
    super.idFrontUrl,
    super.idBackUrl,
    super.bankName,
    super.bankAccount,
    super.accountHolder,
    super.certificatesDescription,
    super.certificateUrls,
    super.avatarUrl,
    super.videoDemoUrl,
    super.verificationStatus,
    super.rejectedReason,
  });

  factory TeacherProfileModel.fromJson(Map<String, dynamic> json) {
    return TeacherProfileModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? '',
      bio: json['bio'] as String?,
      specializations: _toStringList(json['specializations']),
      yearsExperience: _toInt(json['years_experience']),
      teachOnline: json['teach_online'] as bool? ?? false,
      teachOffline: json['teach_offline'] as bool? ?? false,
      locations: _toStringList(json['locations']),
      priceOnline: _toInt(json['price_online']),
      priceOffline: _toInt(json['price_offline']),
      bundle8Sessions: _toInt(json['bundle_8_sessions'], fallback: 8),
      bundle8Discount: json['bundle_8_discount']?.toString() ?? '0',
      bundle12Sessions: _toInt(json['bundle_12_sessions'], fallback: 12),
      bundle12Discount: json['bundle_12_discount']?.toString() ?? '0',
      allowTrialLesson: json['allow_trial_lesson'] as bool? ?? false,
      idNumber: json['id_number'] as String?,
      idFrontUrl: json['id_front_url'] as String?,
      idBackUrl: json['id_back_url'] as String?,
      bankName: json['bank_name'] as String?,
      bankAccount: json['bank_account'] as String?,
      accountHolder: json['account_holder'] as String?,
      certificatesDescription: json['certificates_description'] as String?,
      certificateUrls: _toStringList(json['certificate_urls']),
      avatarUrl: json['avatar_url'] as String?,
      videoDemoUrl: json['video_demo_url'] as String?,
      verificationStatus: json['verification_status'] as String? ?? 'pending',
      rejectedReason: json['rejected_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'bio': bio,
      'specializations': specializations,
      'years_experience': yearsExperience,
      'teach_online': teachOnline,
      'teach_offline': teachOffline,
      'locations': locations,
      'price_online': priceOnline,
      'price_offline': priceOffline,
      'bundle_8_sessions': bundle8Sessions,
      'bundle_8_discount': bundle8Discount,
      'bundle_12_sessions': bundle12Sessions,
      'bundle_12_discount': bundle12Discount,
      'allow_trial_lesson': allowTrialLesson,
      if (idNumber != null) 'id_number': idNumber,
      if (idFrontUrl != null) 'id_front_url': idFrontUrl,
      if (idBackUrl != null) 'id_back_url': idBackUrl,
      if (bankName != null) 'bank_name': bankName,
      if (bankAccount != null) 'bank_account': bankAccount,
      if (accountHolder != null) 'account_holder': accountHolder,
      if (certificatesDescription != null) 'certificates_description': certificatesDescription,
      'certificate_urls': certificateUrls,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (videoDemoUrl != null) 'video_demo_url': videoDemoUrl,
    };
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }
}
