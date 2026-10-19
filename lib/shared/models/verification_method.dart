/// How a worker confirmed an order at handover or collection.
/// Both only check that the right bag goes to the right order; neither
/// proves who the customer or driver is.
enum VerificationMethod {
  qr('QR scan'),
  manual('Manual check');

  const VerificationMethod(this.label);

  final String label;
}
