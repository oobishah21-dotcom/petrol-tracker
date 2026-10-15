class RideEntry {
  final int id;
  final String date;
  final double km;
  final double earnings;
  final double tip;
  final double totalEarnings;
  final double fuelUsed;
  final double fuelCost;
  final double profit;
  final double profitPerKm;
  final double costPerKm;
  final double mileageUsed;
  final String mileageSource;
  final bool hasEstimatedSegment;
  final double estimatedKm;

  RideEntry({
    required this.id,
    required this.date,
    required this.km,
    required this.earnings,
    required this.tip,
    required this.totalEarnings,
    required this.fuelUsed,
    required this.fuelCost,
    required this.profit,
    required this.profitPerKm,
    required this.costPerKm,
    required this.mileageUsed,
    required this.mileageSource,
    this.hasEstimatedSegment = false,
    this.estimatedKm = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'km': km,
        'earnings': earnings,
        'tip': tip,
        'totalEarnings': totalEarnings,
        'fuelUsed': fuelUsed,
        'fuelCost': fuelCost,
        'profit': profit,
        'profitPerKm': profitPerKm,
        'costPerKm': costPerKm,
        'mileageUsed': mileageUsed,
        'mileageSource': mileageSource,
        'hasEstimatedSegment': hasEstimatedSegment,
        'estimatedKm': estimatedKm,
      };

  factory RideEntry.fromJson(Map<String, dynamic> json) => RideEntry(
        id: json['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        date: json['date'] as String? ?? DateTime.now().toIso8601String(),
        km: (json['km'] as num?)?.toDouble() ?? 0.0,
        earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
        tip: (json['tip'] as num?)?.toDouble() ?? 0.0,
        totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
        fuelUsed: (json['fuelUsed'] as num?)?.toDouble() ?? 0.0,
        fuelCost: (json['fuelCost'] as num?)?.toDouble() ?? 0.0,
        profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
        profitPerKm: (json['profitPerKm'] as num?)?.toDouble() ?? 0.0,
        costPerKm: (json['costPerKm'] as num?)?.toDouble() ?? 0.0,
        mileageUsed: (json['mileageUsed'] as num?)?.toDouble() ?? 0.0,
        mileageSource: json['mileageSource'] as String? ?? '',
        hasEstimatedSegment: json['hasEstimatedSegment'] as bool? ?? false,
        estimatedKm: (json['estimatedKm'] as num?)?.toDouble() ?? 0.0,
      );
}
