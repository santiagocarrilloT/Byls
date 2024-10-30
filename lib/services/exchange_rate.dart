class ExchangeRate {
  final String divisaActual;
  final String divisaNueva;
  final double cantidad;

  ExchangeRate({
    required this.divisaActual,
    required this.divisaNueva,
    required this.cantidad,
  });

  factory ExchangeRate.fromJson(
      Map<String, dynamic> json, String from, String to) {
    final String key = '${from}${to}';
    return ExchangeRate(
      divisaActual: from,
      divisaNueva: to,
      cantidad: json['quotes'][key].toDouble(),
    );
  }
}
