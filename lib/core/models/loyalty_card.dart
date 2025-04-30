class LoyaltyCard {
  final String id;
  final String name;
  final String cardNumber;
  final String? barcode;
  final DateTime? expiryDate;
  final String? notes;
  final String description;
  final int points;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoyaltyCard({
    required this.id,
    required this.name,
    required this.cardNumber,
    this.barcode,
    this.expiryDate,
    this.notes,
    this.description = '',
    this.points = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  LoyaltyCard copyWith({
    String? id,
    String? name,
    String? cardNumber,
    String? barcode,
    DateTime? expiryDate,
    String? notes,
    String? description,
    int? points,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoyaltyCard(
      id: id ?? this.id,
      name: name ?? this.name,
      cardNumber: cardNumber ?? this.cardNumber,
      barcode: barcode ?? this.barcode,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      description: description ?? this.description,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cardNumber': cardNumber,
      'barcode': barcode,
      'expiryDate': expiryDate?.toIso8601String(),
      'notes': notes,
      'description': description,
      'points': points,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'] as String,
      name: json['name'] as String,
      cardNumber: json['cardNumber'] as String,
      barcode: json['barcode'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      notes: json['notes'] as String?,
      description: json['description'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
} 