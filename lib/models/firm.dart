/// Mirrors the `firms` table.
class Firm {
  const Firm({
    required this.id,
    required this.firmName,
    this.registrationNumber,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.logoUrl,
    this.subscriptionPlan,
    this.subscriptionStatus,
  });

  final String id;
  final String firmName;
  final String? registrationNumber;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;

  /// Storage path (not a public URL) of the firm logo in the
  /// `profile-images` bucket, e.g. `firms/{firmId}/logo.png`. Resolve to
  /// a viewable URL via `FirmService.getLogoSignedUrl`.
  final String? logoUrl;
  final String? subscriptionPlan;
  final String? subscriptionStatus;

  factory Firm.fromMap(Map<String, dynamic> map) {
    return Firm(
      id: map['id'] as String,
      firmName: map['firm_name'] as String,
      registrationNumber: map['registration_number'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      pincode: map['pincode'] as String?,
      logoUrl: map['logo_url'] as String?,
      subscriptionPlan: map['subscription_plan'] as String?,
      subscriptionStatus: map['subscription_status'] as String?,
    );
  }

  /// Only editable fields — subscription plan/status are managed
  /// elsewhere (billing), not from the firm settings screen. Static
  /// since it only builds a payload from its arguments (no existing
  /// Firm instance needed).
  static Map<String, dynamic> buildUpdateMap({
    String? firmName,
    String? registrationNumber,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
  }) {
    final map = <String, dynamic>{};
    if (firmName != null) map['firm_name'] = firmName;
    if (registrationNumber != null) map['registration_number'] = registrationNumber;
    if (email != null) map['email'] = email;
    if (phone != null) map['phone'] = phone;
    if (address != null) map['address'] = address;
    if (city != null) map['city'] = city;
    if (state != null) map['state'] = state;
    if (pincode != null) map['pincode'] = pincode;
    return map;
  }

  Firm copyWith({String? logoUrl}) {
    return Firm(
      id: id,
      firmName: firmName,
      registrationNumber: registrationNumber,
      email: email,
      phone: phone,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      logoUrl: logoUrl ?? this.logoUrl,
      subscriptionPlan: subscriptionPlan,
      subscriptionStatus: subscriptionStatus,
    );
  }
}
