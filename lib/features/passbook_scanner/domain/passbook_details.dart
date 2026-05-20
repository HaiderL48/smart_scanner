class BankDetails {
  final String? accountHolderName;
  final String? accountNumber;
  final String? ifscCode;

  BankDetails({this.accountHolderName, this.accountNumber, this.ifscCode});

  bool get isEmpty =>
      accountHolderName == null && accountNumber == null && ifscCode == null;

  @override
  String toString() {
    return 'BankDetails(name: $accountHolderName, account: $accountNumber, ifsc: $ifscCode)';
  }
}
