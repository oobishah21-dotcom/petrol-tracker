class Trip {
  final int id;
  final String startTime;
  final String endTime;
  final double distance;
  final bool isActive;
  final bool isRide;
  final double earnings;
  final bool isManual;
  final bool hasEstimatedSegment;
  final double estimatedKm;

  Trip({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.isActive,
    required this.isRide,
    required this.earnings,
    required this.isManual,
    this.hasEstimatedSegment = false,
    this.estimatedKm = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime,
        'endTime': endTime,
        'distance': distance,
        'isActive': isActive,
        'isRide': isRide,
        'earnings': earnings,
        'isManual': isManual,
        'hasEstimatedSegment': hasEstimatedSegment,
        'estimatedKm': estimatedKm,
      };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        startTime: json['startTime'] as String? ?? '',
        endTime: json['endTime'] as String? ?? '',
        distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
        isActive: json['isActive'] as bool? ?? false,
        isRide: json['isRide'] as bool? ?? false,
        earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
        isManual: json['isManual'] as bool? ?? false,
        hasEstimatedSegment: json['hasEstimatedSegment'] as bool? ?? false,
        estimatedKm: (json['estimatedKm'] as num?)?.toDouble() ?? 0.0,
      );

  Trip copyWith({
    int? id,
    String? startTime,
    String? endTime,
    double? distance,
    bool? isActive,
    bool? isRide,
    double? earnings,
    bool? isManual,
    bool? hasEstimatedSegment,
    double? estimatedKm,
  }) {
    return Trip(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distance: distance ?? this.distance,
      isActive: isActive ?? this.isActive,
      isRide: isRide ?? this.isRide,
      earnings: earnings ?? this.earnings,
      isManual: isManual ?? this.isManual,
      hasEstimatedSegment: hasEstimatedSegment ?? this.hasEstimatedSegment,
      estimatedKm: estimatedKm ?? this.estimatedKm,
    );
  }
}
