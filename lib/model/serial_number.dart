
class SerialNumber {
  final String serialNumber;

  SerialNumber(this.serialNumber);

  SerialNumber.fromJSON(Map<String, dynamic> json)
      : serialNumber = json['serial_number'] ?? '';

  Map<String, dynamic> toJSON() => {'serial_number': serialNumber};
  
}
