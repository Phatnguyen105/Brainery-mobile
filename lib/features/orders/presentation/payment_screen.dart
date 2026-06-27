import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_config.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../data/order_models.dart';
import 'order_controller.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({required this.order, super.key});

  final OrderModel order;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class PaymentMethodOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color brandColor;

  const PaymentMethodOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.brandColor,
  });
}

const List<PaymentMethodOption> _paymentMethods = [
  PaymentMethodOption(
    id: 'payos-sandbox',
    title: 'PayOS sandbox (VietQR)',
    description: 'Chuyển khoản ngân hàng bằng QR VietQR',
    icon: Icons.qr_code_scanner_outlined,
    brandColor: Color(0xFF008080),
  ),
  PaymentMethodOption(
    id: 'momo-sandbox',
    title: 'Ví MoMo sandbox',
    description: 'Thanh toán quét mã QR qua ví MoMo Sandbox',
    icon: Icons.account_balance_wallet_outlined,
    brandColor: Color(0xFFA50064),
  ),
  PaymentMethodOption(
    id: 'vnpay-sandbox',
    title: 'VNPay sandbox',
    description: 'Thanh toán quét mã QR qua VNPay Sandbox',
    icon: Icons.account_balance_outlined,
    brandColor: Color(0xFF005AAB),
  ),
];

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  TransactionModel? _transaction;
  String _selectedMethodId = 'payos-sandbox';

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'd');
    final orders = ref.watch(orderControllerProvider);
    final order = widget.order;
    final transaction = _transaction;

    final selectedMethod = _paymentMethods.firstWhere(
      (m) => m.id == (transaction?.provider ?? _selectedMethodId),
      orElse: () => _paymentMethods.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Đơn ${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _MoneyRow(
                      label: 'Tổng tiền',
                      value: currency.format(order.totalAmount),
                    ),
                    if (order.discountAmount > 0)
                      _MoneyRow(
                        label: 'Giảm giá',
                        value: '-${currency.format(order.discountAmount)}',
                      ),
                    const Divider(height: 24),
                    _MoneyRow(
                      label: 'Cần thanh toán',
                      value: currency.format(order.finalPrice),
                      strong: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (transaction == null) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  'Chọn phương thức thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ..._paymentMethods.map((method) {
                final isSelected = _selectedMethodId == method.id;
                return Card(
                  elevation: isSelected ? 2 : 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? method.brandColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () => setState(() => _selectedMethodId = method.id),
                    leading: CircleAvatar(
                      backgroundColor: method.brandColor.withOpacity(0.12),
                      child: Icon(method.icon, color: method.brandColor),
                    ),
                    title: Text(
                      method.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(method.description),
                    trailing: Radio<String>(
                      value: method.id,
                      groupValue: _selectedMethodId,
                      activeColor: method.brandColor,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedMethodId = value);
                        }
                      },
                    ),
                  ),
                );
              }),
            ] else ...[
              Card(
                child: ListTile(
                  leading: Icon(
                    selectedMethod.icon,
                    color: selectedMethod.brandColor,
                  ),
                  title: Text(selectedMethod.title),
                  subtitle: const Text('Thanh toán sandbox qua QR'),
                  trailing: _StatusPill(
                    status: transaction.status,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _PayosTransferCard(
                transaction: transaction,
                amountText: currency.format(order.finalPrice),
                amount: order.finalPrice,
                onScan: orders.isLoading ? null : _openSandboxScanner,
                method: selectedMethod,
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: orders.isLoading
                  ? null
                  : transaction == null
                      ? _createPaymentLink
                      : _openSandboxScanner,
              style: ElevatedButton.styleFrom(
                backgroundColor: transaction == null
                    ? selectedMethod.brandColor
                    : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: orders.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      transaction == null
                          ? Icons.qr_code_2_outlined
                          : Icons.document_scanner_outlined,
                    ),
              label: Text(
                transaction == null
                    ? 'Tạo QR ${selectedMethod.title}'
                    : 'Mở scanner sandbox',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPaymentLink() async {
    final transaction = await ref
        .read(orderControllerProvider.notifier)
        .createTransaction(widget.order, _selectedMethodId);
    if (!mounted) return;
    final state = ref.read(orderControllerProvider);
    if (state.hasError) {
      _showSnack(state.error.toString());
      return;
    }
    setState(() => _transaction = transaction);
    _showSnack('Đã tạo yêu cầu thanh toán sandbox.');
  }

  Future<void> _openSandboxScanner() async {
    final transaction = _transaction;
    if (transaction == null) return;

    final scanned = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _PayosSandboxScannerScreen(transaction: transaction),
      ),
    );
    if (scanned != true || !mounted) return;

    await _confirmSandboxTransfer(transaction);
  }

  Future<void> _confirmSandboxTransfer(TransactionModel transaction) async {
    _showSnack('Đang gửi webhook sandbox...');

    final confirmed = await ref
        .read(orderControllerProvider.notifier)
        .confirmSandbox(transaction);
    if (!mounted) return;
    final state = ref.read(orderControllerProvider);
    if (state.hasError) {
      _showSnack(state.error.toString());
      return;
    }
    setState(() => _transaction = confirmed ?? transaction);
    _showSnack('Sandbox đã xác nhận giao dịch.');
    context.go(RouteNames.learning);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PayosSandboxScannerScreen extends StatefulWidget {
  const _PayosSandboxScannerScreen({required this.transaction});

  final TransactionModel transaction;

  @override
  State<_PayosSandboxScannerScreen> createState() =>
      _PayosSandboxScannerScreenState();
}

class _PayosSandboxScannerScreenState
    extends State<_PayosSandboxScannerScreen> {
  bool _scanning = false;

  @override
  Widget build(BuildContext context) {
    final qrPayload =
        widget.transaction.qrCode ??
        'PAYOS|ORDER|${widget.transaction.orderId}|CODE|${widget.transaction.transactionCode ?? widget.transaction.id}';

    return Scaffold(
      backgroundColor: const Color(0xFF07120F),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF07120F),
        title: const Text('PayOS Sandbox Scanner'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.accent, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(28),
                              child: Text(
                                qrPayload,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          if (_scanning)
                            const Positioned.fill(child: _ScannerSweep()),
                          const Positioned(
                            left: 12,
                            top: 12,
                            child: _CornerBox(alignment: Alignment.topLeft),
                          ),
                          const Positioned(
                            right: 12,
                            top: 12,
                            child: _CornerBox(alignment: Alignment.topRight),
                          ),
                          const Positioned(
                            left: 12,
                            bottom: 12,
                            child: _CornerBox(alignment: Alignment.bottomLeft),
                          ),
                          const Positioned(
                            right: 12,
                            bottom: 12,
                            child: _CornerBox(alignment: Alignment.bottomRight),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _scanning
                    ? 'Đang đọc QR sandbox...'
                    : 'Scanner này chỉ xác nhận giao dịch sandbox, không tạo lệnh chuyển tiền thật.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _scanning ? null : _scan,
                  icon: _scanning
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.qr_code_scanner_outlined),
                  label: Text(_scanning ? 'Đang quét' : 'Quét QR sandbox'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scan() async {
    setState(() => _scanning = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }
}

class _ScannerSweep extends StatefulWidget {
  const _ScannerSweep();

  @override
  State<_ScannerSweep> createState() => _ScannerSweepState();
}

class _ScannerSweepState extends State<_ScannerSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Align(
          alignment: Alignment(0, (_controller.value * 2) - 1),
          child: Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(99),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.accent,
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CornerBox extends StatelessWidget {
  const _CornerBox({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y < 0
                ? const BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
            bottom: alignment.y > 0
                ? const BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
            left: alignment.x < 0
                ? const BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
            right: alignment.x > 0
                ? const BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _PayosTransferCard extends StatelessWidget {
  const _PayosTransferCard({
    required this.transaction,
    required this.amountText,
    required this.amount,
    required this.onScan,
    required this.method,
  });

  final TransactionModel transaction;
  final String amountText;
  final double amount;
  final VoidCallback? onScan;
  final PaymentMethodOption method;

  @override
  Widget build(BuildContext context) {
    final code = transaction.transactionCode ?? transaction.id;
    final qrUrl = _vietQrUrl(amount: amount, addInfo: code);

    String instruction = 'Quét QR hoặc chuyển khoản';
    if (method.id == 'momo-sandbox') {
      instruction = 'Quét QR sandbox qua ví MoMo';
    } else if (method.id == 'vnpay-sandbox') {
      instruction = 'Quét QR sandbox qua ứng dụng VNPay';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code_2, color: method.brandColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    instruction,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onScan,
                style: FilledButton.styleFrom(
                  backgroundColor: method.brandColor,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.qr_code_scanner_outlined),
                label: Text('Quét QR ${method.title}'),
              ),
            ),
            const SizedBox(height: 14),
            AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: method.brandColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      qrUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            transaction.qrCode ?? code,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _InfoRow(label: 'Ngân hàng', value: AppConfig.paymentBankCode),
            _InfoRow(
              label: 'Số tài khoản',
              value: AppConfig.paymentAccountNumber,
            ),
            _InfoRow(
              label: 'Chủ tài khoản',
              value: AppConfig.paymentAccountName,
            ),
            _InfoRow(label: 'Số tiền', value: amountText),
            _InfoRow(label: 'Nội dung', value: code),
            if (transaction.checkoutUrl != null)
              _InfoRow(label: 'Checkout URL', value: transaction.checkoutUrl!),
          ],
        ),
      ),
    );
  }

  String _vietQrUrl({required double amount, required String addInfo}) {
    final amountText = amount.toStringAsFixed(0);
    final bankCode = Uri.encodeComponent(AppConfig.paymentBankCode);
    final account = Uri.encodeComponent(AppConfig.paymentAccountNumber);
    final info = Uri.encodeComponent(addInfo);
    final name = Uri.encodeComponent(AppConfig.paymentAccountName);
    return 'https://img.vietqr.io/image/$bankCode-$account-compact2.png'
        '?amount=$amountText&addInfo=$info&accountName=$name';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final paid = status.toLowerCase() == 'success';
    return Chip(
      label: Text(status),
      visualDensity: VisualDensity.compact,
      backgroundColor: paid ? AppColors.primary.withValues(alpha: 0.14) : null,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 96, child: Text(label)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
