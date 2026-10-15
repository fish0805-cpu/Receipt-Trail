import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../purchases/purchase_models.dart';
import 'merchant_resolver.dart';
import 'receipt_scan_models.dart';
import 'receipt_scanner.dart';
import 'scan_controller.dart';
import 'taiwan_invoice_qr.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    required this.scanner,
    required this.onSaveReceipt,
    this.existingReceipts = const [],
  });

  final ReceiptScanner scanner;
  final Future<void> Function(Receipt receipt) onSaveReceipt;
  final List<Receipt> existingReceipts;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeController = TextEditingController();
  final _addressController = TextEditingController();
  final _numberController = TextEditingController();
  final _totalController = TextEditingController();
  final _sellerTaxIdController = TextEditingController();
  final _subtotalController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _itemEntries = <_ItemEntry>[];
  final _scannerController = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  late final ScanController _scanController;
  int _step = 0;
  bool _handlingScan = false;
  bool _isProcessing = false;
  bool _isSaving = false;
  bool _traditionalReceipt = true;
  SpendingCategory _category = SpendingCategory.food;
  Receipt? _savedReceipt;
  DateTime? _recognizedDate;
  String? _rawText;
  bool _itemsComplete = true;
  List<MerchantCandidate> _merchantCandidates = const [];

  @override
  void initState() {
    super.initState();
    _scanController = ScanController(widget.scanner, disposeScanner: false);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _scanController.dispose();
    _storeController.dispose();
    _addressController.dispose();
    _numberController.dispose();
    _totalController.dispose();
    _sellerTaxIdController.dispose();
    _subtotalController.dispose();
    _discountController.dispose();
    for (final item in _itemEntries) {
      item.dispose();
    }
    super.dispose();
  }

  void _showUnavailable(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_handlingScan || capture.barcodes.isEmpty) return;
    final values = capture.barcodes
        .map((barcode) => barcode.rawValue?.trim())
        .whereType<String>()
        .toList();
    final rawValue = values
        .where((value) => parseTaiwanInvoiceQr(value) != null)
        .firstOrNull;
    if (rawValue == null) return;
    final rightValue =
        values.where((value) => value.startsWith('**')).firstOrNull;
    _handlingScan = true;
    await _scannerController.stop();
    await _scanController.acceptBarcode(rawValue, rightValue: rightValue);
    final draft = _scanController.draft;
    if (draft == null) _scanController.startManualEntry();
    _applyDraft(draft);
    if (!mounted) return;
    setState(() => _step = 1);
    _handlingScan = false;
  }

  void _applyDraft(ReceiptScanDraft? data) {
    if (data == null) return;
    if (data.storeName case final value?) _storeController.text = value;
    if (data.address case final value?) _addressController.text = value;
    if (data.receiptNumber case final value?) _numberController.text = value;
    _recognizedDate = data.date;
    _rawText = data.rawText;
    _sellerTaxIdController.text = data.sellerTaxId ?? '';
    _discountController.text = (data.discount ?? 0).toString();
    _subtotalController.text = data.subtotal?.toString() ?? '';
    for (final item in _itemEntries) {
      item.dispose();
    }
    _itemEntries
      ..clear()
      ..addAll(data.items.map(_ItemEntry.fromItem));
    _itemsComplete = data.itemsComplete;
    _merchantCandidates = MerchantResolver.resolve(
      receipts: widget.existingReceipts,
      sellerTaxId: data.sellerTaxId,
      storeName: data.storeName,
      address: data.address,
    );
    if (data.total case final total? when total > 0) {
      _totalController.text = total.toString();
    }
  }

  Future<void> _pickQrImage() async {
    await _capture(ScanSource.gallery);
  }

  Future<void> _captureReceipt() async {
    await _scannerController.stop();
    await _capture(ScanSource.camera);
  }

  Future<void> _capture(ScanSource source) async {
    setState(() => _isProcessing = true);
    await _scannerController.stop();
    await _scanController.capture(source);
    final draft = _scanController.draft;
    if (draft == null) {
      if (_scanController.failure case final failure?) {
        _showUnavailable(_scanFailureMessage(failure.code));
      }
      await _scannerController.start();
      if (mounted) setState(() => _isProcessing = false);
      return;
    }
    _applyDraft(draft);
    if (mounted) setState(() => _step = 1);
    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _openManualEntry() async {
    await _scannerController.stop();
    _scanController.startManualEntry();
    if (mounted) setState(() => _step = 1);
  }

  Future<void> _resetScanner() async {
    setState(() => _step = 0);
    _handlingScan = false;
    await _scannerController.start();
  }

  Future<void> _chooseDate() async {
    final today = DateTime.now();
    final initial = _recognizedDate;
    final date = await showDatePicker(
      context: context,
      initialDate: initial != null &&
              !initial.isBefore(DateTime(1912)) &&
              !initial.isAfter(today)
          ? initial
          : today,
      firstDate: DateTime(1912),
      lastDate: today,
    );
    if (date != null && mounted) setState(() => _recognizedDate = date);
  }

  void _removeItem(int index) {
    setState(() {
      _itemEntries.removeAt(index).dispose();
    });
  }

  Future<void> _save() async {
    final localizations = AppLocalizations.of(context)!;
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) return;
    if (_recognizedDate case final selected?
        when selected.isBefore(DateTime(1912)) ||
            selected.isAfter(DateTime.now())) {
      _showUnavailable(localizations.dateOutOfRange);
      return;
    }
    final total = int.parse(_totalController.text.trim());
    final discount = int.parse(_discountController.text.trim());
    final subtotal = _subtotalController.text.trim().isEmpty
        ? total + discount
        : int.parse(_subtotalController.text.trim());
    if (subtotal - discount != total) {
      _showUnavailable(localizations.amountMismatch);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final receipt = await _scanController.confirm(
        storeName: _storeController.text.trim(),
        address: _addressController.text.trim(),
        date: _recognizedDate ?? DateTime.now(),
        total: total,
        subtotal: subtotal,
        discount: discount,
        sellerTaxId: _sellerTaxIdController.text.trim(),
        items: _itemEntries.map((item) => item.toReceiptItem()).toList(),
        category: _category,
        receiptNumber: _numberController.text.trim(),
      );
      if (receipt == null) throw StateError('Receipt could not be created');
      await widget.onSaveReceipt(receipt);
      if (mounted) {
        setState(() {
          _savedReceipt = receipt;
          _step = 2;
        });
      }
    } catch (_) {
      _scanController.allowRetryAfterSaveFailure();
      if (mounted) _showUnavailable(localizations.saveFailedKeepData);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text([
          'Receipt Trail',
          localizations.reviewData,
          localizations.saveComplete,
        ][_step]),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: [
            _CaptureStep(
              controller: _scannerController,
              onDetect: _handleBarcode,
              onManualEntry: _openManualEntry,
              onPickImage: _pickQrImage,
              onCaptureReceipt: _captureReceipt,
              isProcessing: _isProcessing,
              traditionalReceipt: _traditionalReceipt,
              onModeChanged: (value) =>
                  setState(() => _traditionalReceipt = value),
            ),
            _ReceiptForm(
              formKey: _formKey,
              storeController: _storeController,
              addressController: _addressController,
              numberController: _numberController,
              totalController: _totalController,
              sellerTaxIdController: _sellerTaxIdController,
              subtotalController: _subtotalController,
              discountController: _discountController,
              date: _recognizedDate ?? DateTime.now(),
              onChooseDate: _chooseDate,
              items: _itemEntries,
              itemsComplete: _itemsComplete,
              merchantCandidates: _merchantCandidates,
              onSelectMerchant: (candidate) => setState(() {
                _storeController.text = candidate.storeName;
                _addressController.text = candidate.address;
                if (candidate.sellerTaxId != null) {
                  _sellerTaxIdController.text = candidate.sellerTaxId!;
                }
                _merchantCandidates = const [];
              }),
              onAddItem: () => setState(() => _itemEntries.add(_ItemEntry())),
              onRemoveItem: _removeItem,
              category: _category,
              onCategoryChanged: (value) => setState(() => _category = value),
              onSave: _save,
              onReset: _resetScanner,
              rawText: _rawText,
              isSaving: _isSaving,
            ),
            _DoneStep(onDone: () => Navigator.pop(context, _savedReceipt)),
          ][_step],
        ),
      ),
    );
  }

  String _scanFailureMessage(ScanFailureCode code) {
    final localizations = AppLocalizations.of(context)!;
    return switch (code) {
      ScanFailureCode.recognitionFailed => localizations.scanFailureRecognition,
      ScanFailureCode.noTextFound => localizations.scanFailureNoText,
      ScanFailureCode.locationUnavailable => localizations.scanFailureLocation,
      ScanFailureCode.unknown => localizations.scanFailureUnknown,
    };
  }
}

class _CaptureStep extends StatelessWidget {
  const _CaptureStep({
    required this.controller,
    required this.onDetect,
    required this.onManualEntry,
    required this.onPickImage,
    required this.onCaptureReceipt,
    required this.isProcessing,
    required this.traditionalReceipt,
    required this.onModeChanged,
  });
  final MobileScannerController controller;
  final ValueChanged<BarcodeCapture> onDetect;
  final VoidCallback onManualEntry;
  final VoidCallback onPickImage;
  final VoidCallback onCaptureReceipt;
  final bool isProcessing;
  final bool traditionalReceipt;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return WarmPageBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
        children: [
          Text(localizations.scanStepOne,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppPalette.forest, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(localizations.scanYourReceipt,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(localizations.chooseReceiptType,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ReceiptModeCard(
                  title: localizations.electronicReceipt,
                  subtitle: localizations.scanLeftQr,
                  selected: !traditionalReceipt,
                  onTap: () => onModeChanged(false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ReceiptModeCard(
                  title: localizations.traditionalReceipt,
                  subtitle: localizations.photographFront,
                  selected: traditionalReceipt,
                  onTap: () => onModeChanged(true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: SizedBox(
              height: 355,
              child: Stack(
                children: [
                  Positioned.fill(
                      child: MobileScanner(
                          controller: controller, onDetect: onDetect)),
                  Positioned.fill(
                      child: ColoredBox(
                          color: Colors.black.withValues(alpha: .34))),
                  if (isProcessing)
                    const Positioned.fill(
                      child: ColoredBox(
                          color: Color(0x99000000),
                          child: Center(child: CircularProgressIndicator())),
                    ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(42, 42, 42, 82),
                      child: CustomPaint(painter: _CornersPainter()),
                    ),
                  ),
                  Positioned(
                    top: 22,
                    right: 18,
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                            onPressed: onPickImage,
                            icon: const Icon(Icons.photo_library_outlined)),
                        const SizedBox(width: 6),
                        IconButton.filledTonal(
                            onPressed: controller.toggleTorch,
                            icon: const Icon(Icons.flash_auto_rounded)),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 22,
                    child: Text(
                      traditionalReceipt
                          ? localizations.traditionalCaptureHint
                          : localizations.electronicCaptureHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          height: 1.45,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: isProcessing ? null : onCaptureReceipt,
            icon: const Icon(Icons.document_scanner_rounded),
            label: Text(traditionalReceipt
                ? localizations.captureTraditional
                : localizations.scanElectronic),
          ),
          TextButton(
            onPressed: isProcessing ? null : onManualEntry,
            child: Text(localizations.manualEntry),
          ),
        ],
      ),
    );
  }
}

class _ReceiptModeCard extends StatelessWidget {
  const _ReceiptModeCard(
      {required this.title,
      required this.subtitle,
      required this.selected,
      required this.onTap});
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? AppPalette.mint : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
              color: selected ? AppPalette.forest : AppPalette.line,
              width: selected ? 1.4 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      );
}

class _ReceiptForm extends StatelessWidget {
  const _ReceiptForm({
    required this.formKey,
    required this.storeController,
    required this.addressController,
    required this.numberController,
    required this.totalController,
    required this.sellerTaxIdController,
    required this.subtotalController,
    required this.discountController,
    required this.date,
    required this.onChooseDate,
    required this.items,
    required this.itemsComplete,
    required this.merchantCandidates,
    required this.onSelectMerchant,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.category,
    required this.onCategoryChanged,
    required this.onSave,
    required this.onReset,
    required this.rawText,
    required this.isSaving,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController storeController;
  final TextEditingController addressController;
  final TextEditingController numberController;
  final TextEditingController totalController;
  final TextEditingController sellerTaxIdController;
  final TextEditingController subtotalController;
  final TextEditingController discountController;
  final DateTime date;
  final VoidCallback onChooseDate;
  final List<_ItemEntry> items;
  final bool itemsComplete;
  final List<MerchantCandidate> merchantCandidates;
  final ValueChanged<MerchantCandidate> onSelectMerchant;
  final VoidCallback onAddItem;
  final ValueChanged<int> onRemoveItem;
  final SpendingCategory category;
  final ValueChanged<SpendingCategory> onCategoryChanged;
  final VoidCallback onSave;
  final VoidCallback onReset;
  final String? rawText;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _StatusBanner(
            icon: Icons.edit_note_rounded,
            title: localizations.enterReceiptContent,
            subtitle: localizations.receiptContentSubtitle,
          ),
          const SizedBox(height: 20),
          if (merchantCandidates.isNotEmpty) ...[
            Text(localizations.possibleSavedMerchant,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...merchantCandidates.map((candidate) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () => onSelectMerchant(candidate),
                    child: Text(candidate.storeName),
                  ),
                )),
            const SizedBox(height: 8),
          ],
          TextFormField(
            controller: storeController,
            decoration:
                InputDecoration(labelText: localizations.merchantNameRequired),
            validator: (value) => value == null || value.trim().isEmpty
                ? localizations.enterMerchantName
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
              controller: addressController,
              decoration: InputDecoration(labelText: localizations.address)),
          const SizedBox(height: 12),
          TextFormField(
              controller: numberController,
              decoration:
                  InputDecoration(labelText: localizations.receiptNumber)),
          const SizedBox(height: 12),
          TextFormField(
            controller: sellerTaxIdController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: localizations.sellerTaxId),
            validator: (value) {
              final text = value?.trim() ?? '';
              return text.isEmpty || RegExp(r'^\d{8}$').hasMatch(text)
                  ? null
                  : localizations.sellerTaxIdInvalid;
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onChooseDate,
            icon: const Icon(Icons.event_outlined),
            label: Text(localizations.purchaseDate(
              '${date.year}/${date.month}/${date.day}',
            )),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: totalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: localizations.totalAmountRequired,
                prefixText: 'NT\$ '),
            validator: (value) {
              final amount = int.tryParse(value?.trim() ?? '');
              return amount == null || amount <= 0
                  ? localizations.enterValidAmount
                  : null;
            },
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: subtotalController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: localizations.itemsSubtotal),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return null;
                  final amount = int.tryParse(text);
                  return amount == null || amount < 0
                      ? localizations.enterValidSubtotal
                      : null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: localizations.discount),
                validator: (value) {
                  final amount = int.tryParse(value?.trim() ?? '');
                  return amount == null || amount < 0
                      ? localizations.enterValidDiscount
                      : null;
                },
              ),
            ),
          ]),
          const SizedBox(height: 18),
          DropdownButtonFormField<SpendingCategory>(
            initialValue: category,
            decoration:
                InputDecoration(labelText: localizations.spendingCategory),
            items: SpendingCategory.values
                .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(_scanCategoryLabel(localizations, value))))
                .toList(),
            onChanged: (value) {
              if (value != null) onCategoryChanged(value);
            },
          ),
          const SizedBox(height: 18),
          Text(localizations.purchaseItemRows,
              style: Theme.of(context).textTheme.titleMedium),
          if (!itemsComplete && items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(localizations.itemsMayBeIncomplete),
            ),
          for (var index = 0; index < items.length; index++) ...[
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: items[index].name,
                        decoration:
                            InputDecoration(labelText: localizations.itemName),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? localizations.enterItemName
                                : null,
                      ),
                    ),
                    IconButton(
                      onPressed: () => onRemoveItem(index),
                      tooltip: localizations.removeItem,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: items[index].quantity,
                        keyboardType: TextInputType.number,
                        decoration:
                            InputDecoration(labelText: localizations.quantity),
                        validator: (value) {
                          final amount = int.tryParse(value?.trim() ?? '');
                          return amount == null || amount < 1
                              ? localizations.quantityAtLeastOne
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: items[index].unitPrice,
                        keyboardType: TextInputType.number,
                        decoration:
                            InputDecoration(labelText: localizations.unitPrice),
                        validator: (value) {
                          final amount = int.tryParse(value?.trim() ?? '');
                          return amount == null || amount < 0
                              ? localizations.enterValidUnitPrice
                              : null;
                        },
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
          ],
          OutlinedButton.icon(
            onPressed: onAddItem,
            icon: const Icon(Icons.add_rounded),
            label: Text(localizations.addItem),
          ),
          if (rawText != null) ...[
            const SizedBox(height: 18),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              leading: const Icon(Icons.text_snippet_outlined),
              title: Text(localizations.rawOcrText),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SelectableText(rawText!),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: isSaving ? null : onSave,
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: isSaving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(localizations.confirmAndSave)),
          ),
          TextButton(onPressed: onReset, child: Text(localizations.goBack)),
        ],
      ),
    );
  }
}

String _scanCategoryLabel(
  AppLocalizations localizations,
  SpendingCategory category,
) =>
    switch (category) {
      SpendingCategory.food => localizations.categoryFood,
      SpendingCategory.shopping => localizations.categoryShopping,
      SpendingCategory.transport => localizations.categoryTransport,
      SpendingCategory.other => localizations.categoryOther,
    };

class _ItemEntry {
  _ItemEntry({String name = '', int quantity = 1, int unitPrice = 0})
      : name = TextEditingController(text: name),
        quantity = TextEditingController(text: quantity.toString()),
        unitPrice = TextEditingController(text: unitPrice.toString());

  factory _ItemEntry.fromItem(ReceiptItem item) => _ItemEntry(
        name: item.name,
        quantity: item.quantity,
        unitPrice: item.price,
      );

  final TextEditingController name;
  final TextEditingController quantity;
  final TextEditingController unitPrice;

  ReceiptItem toReceiptItem() => ReceiptItem(
        name: name.text.trim(),
        quantity: int.parse(quantity.text.trim()),
        price: int.parse(unitPrice.text.trim()),
      );

  void dispose() {
    name.dispose();
    quantity.dispose();
    unitPrice.dispose();
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            child: Icon(Icons.check_rounded,
                size: 52, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(localizations.receiptAdded,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(localizations.receiptAddedBody, textAlign: TextAlign.center),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onDone,
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(localizations.backHome)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
        ]),
      );
}

class _CornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const length = 38.0;
    canvas.drawLine(Offset.zero, const Offset(length, 0), paint);
    canvas.drawLine(Offset.zero, const Offset(0, length), paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width - length, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);
    canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(0, size.height - length), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - length, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - length), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
