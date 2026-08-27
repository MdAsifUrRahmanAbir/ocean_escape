import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ui/primary_button.dart';

// ---------------------------------------------------------------------------
// Developer / business / payment details - the only place these need
// editing. Everything below just renders these values.
// ---------------------------------------------------------------------------
const String kDevName = 'MD. Asif-Ur-Rahman Abir';
const String kDevRole = 'Flutter & Game Developer';
const String kDevPortfolioUrl = 'https://abirdev.com';
const String kDevPortfolioDisplay = 'abirdev.com';

const String kWhatsappPersonalDisplay = '+8801877348044';
const String kWhatsappPersonalUrl = 'https://wa.me/8801877348044';

const String kBizName = 'AmisysX';
const String kBizTagline =
    'Need a full app or system built? Web, App, E-Commerce or SaaS — any kind.';
const String kBizWebsiteUrl = 'https://amisysx.com/';
const String kBizWebsiteDisplay = 'amisysx.com';
const String kBizFacebookUrl = 'https://fb.com/amisysx';
const String kBizFacebookDisplay = 'fb.com/amisysx';
const String kBizLinkedInUrl = 'https://linkedin.com/company/amisysx';
const String kBizLinkedInDisplay = 'linkedin.com/company/amisysx';
const String kWhatsappBusinessDisplay = '+8801920780034';
const String kWhatsappBusinessUrl = 'https://wa.me/8801920780034';

const String kBkashNumber = '01877348044';

const String kBankAccountNumber = '1060806840001';
const String kBankAccountName = 'MD.ASIF-UR-RAHMAN ABIR';
const String kBankName = 'BRAC Bank PLC';
const String kBankBranch = 'DAKHIN KHAN SUB BRANCH';
const String kBankRouting = '060260914';
const String kBankSwift = 'BRAKBDDH';

class CoffeeOption {
  final String label;
  final int? price; // null => custom amount typed in by the user
  const CoffeeOption(this.label, this.price);
}

const List<CoffeeOption> kCoffeeOptions = [
  CoffeeOption('Hot Coffee', 50),
  CoffeeOption('Cold Coffee', 70),
  CoffeeOption('Latte', 90),
  CoffeeOption('Cappuccino', 90),
  CoffeeOption('Others', null),
];

Future<void> _openUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open $url')),
    );
  }
}

Future<void> _copyToClipboard(BuildContext context, String label, String value) async {
  await Clipboard.setData(ClipboardData(text: value));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied'), duration: const Duration(seconds: 1)),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3949AB), Color(0xFF1A1330)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'About',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 8, bottom: 28),
                    children: [
                      const _DeveloperHeader(),
                      const SizedBox(height: 22),
                      _SectionCard(
                        title: 'Connect',
                        icon: Icons.link_rounded,
                        children: [
                          _LinkRow(
                            icon: Icons.chat_rounded,
                            label: 'WhatsApp',
                            value: kWhatsappPersonalDisplay,
                            url: kWhatsappPersonalUrl,
                          ),
                          _LinkRow(
                            icon: Icons.public_rounded,
                            label: 'Portfolio',
                            value: kDevPortfolioDisplay,
                            url: kDevPortfolioUrl,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _BusinessSection(),
                      const SizedBox(height: 16),
                      const _CoffeeSection(),
                      const SizedBox(height: 16),
                      const _SupportSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeveloperHeader extends StatelessWidget {
  const _DeveloperHeader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.35), blurRadius: 26, spreadRadius: 2),
              ],
            ),
            child: const Icon(Icons.code_rounded, size: 44, color: Color(0xFF1A1330)),
          ),
          const SizedBox(height: 14),
          const Text(
            kDevName,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            kDevRole,
            style: TextStyle(color: Colors.amber.shade200, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.4),
          ),
        ],
      ),
    );
  }
}

/// Full-width panel matching the game's panel color/border/shadow language,
/// used throughout the rest of the app's overlays.
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2140).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFFC107), size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String url;
  const _LinkRow({required this.icon, required this.label, required this.value, required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openUrl(context, url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w600)),
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Icon(Icons.north_east_rounded, color: Colors.white.withValues(alpha: 0.5), size: 16),
          ],
        ),
      ),
    );
  }
}

class _CopyableField extends StatelessWidget {
  final String label;
  final String value;
  const _CopyableField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _copyToClipboard(context, label, value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11, fontWeight: FontWeight.w600)),
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Icon(Icons.copy_rounded, color: Colors.white.withValues(alpha: 0.5), size: 16),
          ],
        ),
      ),
    );
  }
}

class _BusinessSection extends StatelessWidget {
  const _BusinessSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: kBizName,
      icon: Icons.business_center_rounded,
      children: [
        Text(kBizTagline, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, height: 1.4)),
        const SizedBox(height: 8),
        _LinkRow(icon: Icons.language_rounded, label: 'Website', value: kBizWebsiteDisplay, url: kBizWebsiteUrl),
        _LinkRow(icon: Icons.facebook_rounded, label: 'Facebook', value: kBizFacebookDisplay, url: kBizFacebookUrl),
        _LinkRow(icon: Icons.business_rounded, label: 'LinkedIn', value: kBizLinkedInDisplay, url: kBizLinkedInUrl),
        _LinkRow(
          icon: Icons.chat_rounded,
          label: 'WhatsApp (Business)',
          value: kWhatsappBusinessDisplay,
          url: kWhatsappBusinessUrl,
        ),
      ],
    );
  }
}

class _SupportSection extends StatelessWidget {
  const _SupportSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Support the Developer',
      icon: Icons.favorite_rounded,
      children: [
        Text('bKash (Send Money) — Bangladesh only',
            style: TextStyle(color: Colors.amber.shade200, fontSize: 12, fontWeight: FontWeight.w700)),
        const _CopyableField(label: 'bKash Number', value: kBkashNumber),
        const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Divider(color: Colors.white24, height: 1)),
        Text('Bank Transfer — Bangladesh & International (USD)',
            style: TextStyle(color: Colors.amber.shade200, fontSize: 12, fontWeight: FontWeight.w700)),
        const _CopyableField(label: 'Account Number', value: kBankAccountNumber),
        const _CopyableField(label: 'Account Name', value: kBankAccountName),
        const _CopyableField(label: 'Bank Name', value: kBankName),
        const _CopyableField(label: 'Branch Name', value: kBankBranch),
        const _CopyableField(label: 'Routing Number', value: kBankRouting),
        const _CopyableField(label: 'SWIFT Code', value: kBankSwift),
      ],
    );
  }
}

class _CoffeeSection extends StatelessWidget {
  const _CoffeeSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Buy Me A Coffee',
      icon: Icons.coffee_rounded,
      children: [
        Text(
          'Enjoying the game? A small coffee keeps me going!',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          label: 'Buy Me A Coffee',
          icon: Icons.coffee_rounded,
          color: const Color(0xFF8D6E63),
          width: double.infinity,
          onPressed: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => const _CoffeeFlowSheet(),
          ),
        ),
      ],
    );
  }
}

class _CoffeeFlowSheet extends StatefulWidget {
  const _CoffeeFlowSheet();

  @override
  State<_CoffeeFlowSheet> createState() => _CoffeeFlowSheetState();
}

class _CoffeeFlowSheetState extends State<_CoffeeFlowSheet> {
  CoffeeOption? _selected;
  final _customController = TextEditingController();
  bool _showPayment = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  int? get _amount {
    final sel = _selected;
    if (sel == null) return null;
    if (sel.price != null) return sel.price;
    return int.tryParse(_customController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF241A3B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _showPayment ? 'Complete Your Coffee' : 'Pick Your Coffee',
              style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (!_showPayment) ..._buildPicker(context) else ..._buildPayment(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPicker(BuildContext context) {
    return [
      ...kCoffeeOptions.map(
        (opt) => RadioListTile<CoffeeOption>(
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFFFFC107),
          title: Text(
            opt.price != null ? '${opt.label} — ৳${opt.price}' : opt.label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          value: opt,
          groupValue: _selected,
          onChanged: (v) => setState(() => _selected = v),
        ),
      ),
      if (_selected != null && _selected!.price == null) ...[
        const SizedBox(height: 4),
        TextField(
          controller: _customController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixText: '৳ ',
            prefixStyle: const TextStyle(color: Colors.white),
            hintText: 'Enter amount',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
      const SizedBox(height: 18),
      PrimaryButton(
        label: 'Continue',
        icon: Icons.arrow_forward_rounded,
        color: const Color(0xFF00C853),
        width: double.infinity,
        onPressed: () {
          final amt = _amount;
          if (amt != null && amt > 0) {
            setState(() => _showPayment = true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Choose a coffee or enter an amount')),
            );
          }
        },
      ),
    ];
  }

  List<Widget> _buildPayment() {
    final amount = _amount ?? 0;
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Text(_selected?.label ?? 'Coffee', style: TextStyle(color: Colors.amber.shade200, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('৳$amount', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text('bKash (Send Money) — Bangladesh only',
          style: TextStyle(color: Colors.amber.shade200, fontSize: 12, fontWeight: FontWeight.w700)),
      const _CopyableField(label: 'bKash Number', value: kBkashNumber),
      const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Divider(color: Colors.white24, height: 1)),
      Text('Bank Transfer — Bangladesh & International',
          style: TextStyle(color: Colors.amber.shade200, fontSize: 12, fontWeight: FontWeight.w700)),
      const _CopyableField(label: 'Account Number', value: kBankAccountNumber),
      const _CopyableField(label: 'Account Name', value: kBankAccountName),
      const _CopyableField(label: 'Bank Name', value: kBankName),
      const _CopyableField(label: 'Branch Name', value: kBankBranch),
      const _CopyableField(label: 'Routing Number', value: kBankRouting),
      const _CopyableField(label: 'SWIFT Code', value: kBankSwift),
      const SizedBox(height: 16),
      PrimaryButton(
        label: 'Done',
        icon: Icons.check_rounded,
        color: const Color(0xFF00ACC1),
        width: double.infinity,
        onPressed: () => Navigator.of(context).pop(),
      ),
    ];
  }
}
