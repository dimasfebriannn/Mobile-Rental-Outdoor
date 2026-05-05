import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  AppState._internal();
  static final AppState instance = AppState._internal();

  ProfileData profile = ProfileData(
    name: 'Dimas Febrian',
    email: 'dimas@example.com',
    phone: '+62 812 3456 7890',
    address: 'Jl. Mawar No. 12, Bandung',
    birthdate: '12 Januari 1992',
    memberStatus: 'Platinum Member',
    memberSince: '24 Mei 2023',
    ktp: '3201 1234 5678 9012',
    gender: 'Laki-laki',
    job: 'Freelancer',
  );

  List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      label: 'Visa Debit',
      details: '•••• 1234 · Exp 07/26',
      value: 'Visa •••• 1234',
      icon: Icons.credit_card_rounded,
    ),
    PaymentMethod(
      label: 'GoPay',
      details: 'Saldo: Rp 450.000',
      value: 'GoPay',
      icon: Icons.mobile_friendly_rounded,
    ),
    PaymentMethod(
      label: 'Bank Mandiri',
      details: 'Rekening aktif •••• 7890',
      value: 'Bank Mandiri',
      icon: Icons.account_balance_rounded,
    ),
  ];
  String selectedPaymentMethod = 'Visa •••• 1234';

  NotificationSettings notificationSettings = NotificationSettings(
    orderUpdates: true,
    promoAlerts: true,
    reminderAlerts: true,
    appNews: false,
  );

  SecuritySettings securitySettings = SecuritySettings(
    faceId: true,
    twoFactor: true,
    deviceAlerts: true,
  );

  List<VoucherData> vouchers = [
    VoucherData(
      title: 'Diskon 15%',
      code: 'MAJELIS15',
      expiry: 'Berlaku sampai 30 Mei 2026',
      description: 'Potongan 15% untuk semua sewa alat outdoor.',
      color: const Color(0xFFFFF3D8),
      icon: Icons.local_offer_rounded,
    ),
    VoucherData(
      title: 'Potongan Rp 25.000',
      code: 'OUTDOOR25',
      expiry: 'Berlaku sampai 15 Juni 2026',
      description: 'Diskon tambahan untuk sewa lebih dari Rp 250.000.',
      color: const Color(0xFFEDE7FF),
      icon: Icons.card_giftcard_rounded,
    ),
    VoucherData(
      title: 'Gratis Pengiriman',
      code: 'FREEDEL',
      expiry: 'Berlaku sampai 10 Juli 2026',
      description: 'Tidak dikenakan biaya pengiriman untuk sewa peralatan.',
      color: const Color(0xFFE9F7EF),
      icon: Icons.local_shipping_rounded,
    ),
  ];

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? ktp,
    String? job,
  }) {
    profile = profile.copyWith(
      name: name,
      email: email,
      phone: phone,
      address: address,
      ktp: ktp,
      job: job,
    );
    notifyListeners();
  }

  void selectPaymentMethod(String value) {
    selectedPaymentMethod = value;
    notifyListeners();
  }

  void updateNotificationSettings({
    bool? orderUpdates,
    bool? promoAlerts,
    bool? reminderAlerts,
    bool? appNews,
  }) {
    notificationSettings = notificationSettings.copyWith(
      orderUpdates: orderUpdates,
      promoAlerts: promoAlerts,
      reminderAlerts: reminderAlerts,
      appNews: appNews,
    );
    notifyListeners();
  }

  void updateSecuritySettings({
    bool? faceId,
    bool? twoFactor,
    bool? deviceAlerts,
  }) {
    securitySettings = securitySettings.copyWith(
      faceId: faceId,
      twoFactor: twoFactor,
      deviceAlerts: deviceAlerts,
    );
    notifyListeners();
  }
}

class ProfileData {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String birthdate;
  final String memberStatus;
  final String memberSince;
  final String ktp;
  final String gender;
  final String job;

  ProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.birthdate,
    required this.memberStatus,
    required this.memberSince,
    required this.ktp,
    required this.gender,
    required this.job,
  });

  get role => null;

  ProfileData copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? birthdate,
    String? memberStatus,
    String? memberSince,
    String? ktp,
    String? gender,
    String? job,
  }) {
    return ProfileData(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      birthdate: birthdate ?? this.birthdate,
      memberStatus: memberStatus ?? this.memberStatus,
      memberSince: memberSince ?? this.memberSince,
      ktp: ktp ?? this.ktp,
      gender: gender ?? this.gender,
      job: job ?? this.job,
    );
  }
}

class PaymentMethod {
  final String label;
  final String details;
  final String value;
  final IconData icon;

  PaymentMethod({
    required this.label,
    required this.details,
    required this.value,
    required this.icon,
  });
}

class NotificationSettings {
  final bool orderUpdates;
  final bool promoAlerts;
  final bool reminderAlerts;
  final bool appNews;

  NotificationSettings({
    required this.orderUpdates,
    required this.promoAlerts,
    required this.reminderAlerts,
    required this.appNews,
  });

  NotificationSettings copyWith({
    bool? orderUpdates,
    bool? promoAlerts,
    bool? reminderAlerts,
    bool? appNews,
  }) {
    return NotificationSettings(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promoAlerts: promoAlerts ?? this.promoAlerts,
      reminderAlerts: reminderAlerts ?? this.reminderAlerts,
      appNews: appNews ?? this.appNews,
    );
  }
}

class SecuritySettings {
  final bool faceId;
  final bool twoFactor;
  final bool deviceAlerts;

  SecuritySettings({
    required this.faceId,
    required this.twoFactor,
    required this.deviceAlerts,
  });

  SecuritySettings copyWith({
    bool? faceId,
    bool? twoFactor,
    bool? deviceAlerts,
  }) {
    return SecuritySettings(
      faceId: faceId ?? this.faceId,
      twoFactor: twoFactor ?? this.twoFactor,
      deviceAlerts: deviceAlerts ?? this.deviceAlerts,
    );
  }
}

class VoucherData {
  final String title;
  final String code;
  final String expiry;
  final String description;
  final Color color;
  final IconData icon;

  VoucherData({
    required this.title,
    required this.code,
    required this.expiry,
    required this.description,
    required this.color,
    required this.icon,
  });
}
