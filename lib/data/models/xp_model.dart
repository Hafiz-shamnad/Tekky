class XPModel {
  final int xp;
  final int level;
  final DateTime? lastDailyXP;

  XPModel({
    required this.xp,
    required this.level,
    this.lastDailyXP,
  });

  factory XPModel.fromJson(Map<String, dynamic> json) {
    return XPModel(
      xp: json["xp"],
      level: json["level"],
      lastDailyXP:
          json["lastDailyXP"] != null ? DateTime.parse(json["lastDailyXP"]) : null,
    );
  }
}
