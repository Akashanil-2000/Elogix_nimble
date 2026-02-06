import 'dart:convert';
import 'dart:io';
import 'package:elogix_nimble/service/delivery_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class DeliveryConfirmationPage extends StatefulWidget {
  final int serviceId;
  final double codAmount;
  final String? wayBillNumber;

  const DeliveryConfirmationPage({
    super.key,
    required this.serviceId,
    required this.codAmount,
    required this.wayBillNumber,
  });

  @override
  State<DeliveryConfirmationPage> createState() =>
      _DeliveryConfirmationPageState();
}

class _DeliveryConfirmationPageState extends State<DeliveryConfirmationPage> {
  final receiverCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  bool isSubmitting = false;
  final ImagePicker picker = ImagePicker();
  final List<File> images = [];
  bool isAwbScanned = false;

  String? awbNumber;

  // ───────────────── IMAGE PICKER ─────────────────

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      final List<XFile> pickedFiles = await picker.pickMultiImage(
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          images.addAll(pickedFiles.map((e) => File(e.path)));
        });
      }
    } else {
      final XFile? picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (picked != null) {
        setState(() {
          images.add(File(picked.path));
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() => images.removeAt(index));
  }

  void _showImageSourcePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── QR SCANNER ─────────────────

  void _openQrScanner() {
    bool scanned = false;
    bool errorShown = false;

    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text(
            'Scan AWB',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Stack(
          children: [
            /// 📷 CAMERA VIEW
            MobileScanner(
              fit: BoxFit.cover,
              onDetect: (capture) {
                if (scanned) return;

                final barcode = capture.barcodes.first;
                final value = barcode.rawValue;

                if (value != null && value.isNotEmpty) {
                  // 🔒 Check against backend AWB
                  if (widget.wayBillNumber != null &&
                      value != widget.wayBillNumber) {
                    if (!errorShown) {
                      errorShown = true;

                      Get.snackbar(
                        'Invalid AWB',
                        'This AWB does not match this service',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );

                      // allow scanner again after 2 seconds
                      Future.delayed(const Duration(seconds: 2), () {
                        errorShown = false;
                      });
                    }
                    return;
                  }

                  scanned = true;
                  awbNumber = value;
                  isAwbScanned = true; // 🔥 ADD THIS

                  Get.back();
                  setState(() {});
                }
              },
            ),

            /// 🟩 SCANNER OVERLAY
            Center(
              child: Container(
                width: 260,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.greenAccent, width: 2),
                ),
              ),
            ),

            /// 📝 INSTRUCTION TEXT
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Column(
                children: const [
                  Text(
                    'Align the QR code inside the frame',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Scanning will happen automatically',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── SUBMIT ─────────────────

  void _submit() async {
    if (isSubmitting) return; // prevent double click

    setState(() => isSubmitting = true);

    try {
      print('SUBMIT CLICKED');

      // AWB REQUIRED
      // MUST SCAN AWB
      if (!isAwbScanned) {
        setState(() => isSubmitting = false);
        return _showError('Please scan AWB before submitting');
      }

      // AWB MATCH CHECK
      if (widget.wayBillNumber != null && awbNumber != widget.wayBillNumber) {
        setState(() => isSubmitting = false);
        return _showError('AWB does not match this delivery');
      }

      if (receiverCtrl.text.trim().isEmpty) {
        setState(() => isSubmitting = false);
        return _showError('Receiver Name is required');
      }

      if (amountCtrl.text.trim().isEmpty) {
        setState(() => isSubmitting = false);
        return _showError('Amount is required');
      }
      if (images.isEmpty) {
        setState(() => isSubmitting = false);
        return _showError('Please upload at least one image');
      }

      final attachments = await _buildAttachments();

      final payload = {
        "receiver_name": receiverCtrl.text.trim(),
        "awb_number": awbNumber,
        "amount_received": double.parse(amountCtrl.text),
        "attachments": attachments,
      };

      await DeliveryService().confirmDelivery(
        serviceId: widget.serviceId,
        payload: payload,
      );

      Get.offAllNamed('/dashboard');
      Get.snackbar('Success', 'Delivery confirmed');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _showError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Delivery Confirmation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _openQrScanner,
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          /// 📦 AWB DISPLAY
          ///
          if (widget.wayBillNumber != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AWB: ${widget.wayBillNumber}',

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  isAwbScanned
                      ? const Icon(Icons.verified, color: Colors.green)
                      : IconButton(
                        icon: const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.green,
                        ),
                        onPressed: _openQrScanner,
                      ),
                ],
              ),
            ),

          _inputField(
            label: 'Receiver Name',
            controller: receiverCtrl,
            hint: 'Enter receiver name',
          ),

          const SizedBox(height: 16),

          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'COD Amount: ₹${widget.codAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          _inputField(
            label: 'Amount Received',
            controller: amountCtrl,
            hint: 'Enter amount',
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 24),

          /// 📸 PROOF OF DELIVERY CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Proof of Delivery',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _showImageSourcePicker,
                      icon: const Icon(Icons.camera_alt, size: 16),
                      label: const Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// EMPTY STATE
                if (images.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: const [
                        Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No images added',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                /// GRID
                if (images.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: images.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemBuilder: (_, i) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              images[i],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(i),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),

      /// 🔹 SUBMIT BUTTON
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: isSubmitting ? null : _submit,

            child:
                isSubmitting
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      'SUBMIT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  /// 🧩 INPUT FIELD
  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.green),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _buildAttachments() async {
    List<Map<String, dynamic>> files = [];

    for (var img in images) {
      final bytes = await img.readAsBytes();
      final base64 = base64Encode(bytes);

      files.add({
        "name": img.path.split('/').last,
        "datas": base64,
        "description": "pod",
        "mimetype": "image/jpeg",
      });
    }

    return files;
  }

  @override
  void dispose() {
    receiverCtrl.dispose();
    amountCtrl.dispose();
    super.dispose();
  }
}
