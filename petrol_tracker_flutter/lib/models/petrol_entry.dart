class PetrolEntry {
  final int id;
  final double litres;
  final double pricePerLitre;
  final double totalCost;
  final String date;
  final double kmTraveled;
  final double mainTankDistance;
  final double reserveDistance;
  final double mileage;
  final bool isEstimated;
  final String createdAt;

  PetrolEntry({
    required this.id,
    required this.litres,
    required this.pricePerLitre,
    required this.totalCost,
    required this.date,
    required this.kmTraveled,
    required this.mainTankDistance,
    required this.reserveDistance,
    required this.mileage,
    required this.isEstimated,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'litres': litres,
        'pricePerLitre': pricePerLitre,
        'totalCost': totalCost,
        'date': date,
        'kmTraveled': kmTraveled,
        'mainTankDistance': mainTankDistance,
        'reserveDistance': reserveDistance,
        'mileage': mileage,
        'isEstimated': isEstimated,
        'createdAt': createdAt,
      };

  factory PetrolEntry.fromJson(Map<String, dynamic> json) {
    final double totalKm = (json['kmTraveled'] as num?)?.toDouble() ?? 0.0;
    final double reserve = (json['reserveDistance'] as num?)?.toDouble() ?? 0.0;
    final double mainTank = (json['mainTankDistance'] as num?)?.toDouble() ?? (totalKm - reserve);

    return PetrolEntry(
      id: json['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      litres: (json['litres'] as num?)?.toDouble() ?? 0.0,
      pricePerLitre: (json['pricePerLitre'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] as String? ?? DateTime.now().toIso8601String().split('T')[0],
      kmTraveled: totalKm,
      mainTankDistance: mainTank > 0 ? mainTank : 0.0,
      reserveDistance: reserve,
      mileage: (json['mileage'] as num?)?.toDouble() ?? 0.0,
      isEstimated: json['isEstimated'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
