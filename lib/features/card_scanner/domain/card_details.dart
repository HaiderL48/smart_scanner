class CardDetails {
  final String? cardNumber;
  final String? maskedCardNumber;
  final String? expiryDate;
  final String? cardHolderName;

  CardDetails({
    this.cardNumber,
    this.maskedCardNumber,
    this.expiryDate,
    this.cardHolderName,
  });

  bool get isEmpty =>
      cardNumber == null && expiryDate == null && cardHolderName == null;

  @override
  String toString() {
    return 'CardDetails(cardNumber: $maskedCardNumber, expiry: $expiryDate, name: $cardHolderName)';
  }
}