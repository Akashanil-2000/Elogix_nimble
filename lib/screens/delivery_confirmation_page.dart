import 'dart:convert';
import 'dart:io';
import 'package:elogix_nimble/service/delivery_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class DeliveryConfirmationPage extends StatefulWidget {
  final int serviceId;

  const DeliveryConfirmationPage({super.key, required this.serviceId});

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

  String? awbNumber;

  // ───────────────── IMAGE PICKER ─────────────────

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
                  scanned = true;
                  awbNumber = value;

                  Get.back();
                  setState(() {});

                  Get.snackbar(
                    'Scanned',
                    'AWB: $value',
                    snackPosition: SnackPosition.BOTTOM,
                  );
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

      if (awbNumber == null) {
        setState(() => isSubmitting = false);
        return _showError('Please scan AWB number');
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
          if (awbNumber != null)
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
                      'AWB: $awbNumber',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.green),
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

          _inputField(
            label: 'Amount Received',
            controller: amountCtrl,
            hint: 'Enter amount',
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 24),

          /// 📸 IMAGES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Proof of Delivery',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: _showImageSourcePicker,
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (images.isEmpty)
            const Text('No images added', style: TextStyle(color: Colors.grey)),

          if (images.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
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
