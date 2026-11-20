import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../res/assets_res.dart';
import '../ui/banner_ad_view.dart';

// ---------------------------------------------------------------------------
// Developer / business details - the only place these need editing.
// ---------------------------------------------------------------------------
const String kDevName = 'MD. Asif-Ur-Rahman Abir';
const String kDevRole = 'Flutter & Game Developer';
const String kDevPortfolioUrl = 'https://abirdev.com';
const String kDevPortfolioDisplay = 'abirdev.com';
const String kWhatsappPersonalUrl = 'https://wa.me/8801877348044';

const String kBizName = 'AmisysX';
const String kBizTagline =
    'Need a full app or system built? We design and build Web apps, Mobile apps, '
    'E-Commerce platforms and SaaS products - end to end.';
const List<String> kBizServices = ['Web', 'Mobile App', 'E-Commerce', 'SaaS', 'Games'];
const String kBizWebsiteUrl = 'https://amisysx.com/';
const String kBizWebsiteDisplay = 'amisysx.com';
const String kBizFacebookUrl = 'https://fb.com/amisysx';
const String kBizLinkedInUrl = 'https://linkedin.com/company/amisysx';
const String kWhatsappBusinessUrl = 'https://wa.me/8801920780034';

const String kGameDescription =
    'Guide your little fish through four ever-changing ocean zones. Dodge sharks, '
    'mines and wrecks, grab pearls and power-ups, earn gold and unlock a whole '
    'school of new fish to swim with.';

const _accent = Color(0xFFFFD54F);
const _panel = Color(0xFF0B2A54);

String get _appVersion => AssetsRes.PROJECT_VERSION.split('+').first;

Future<void> _openUrl(BuildContext context, String url) async {
  final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open $url')));
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
            colors: [Color(0xFF1E9BC7), Color(0xFF0B2A54), Color(0xFF061833)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    const Text(
                      'About',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 640;
                    const gap = SizedBox(width: 14, height: 14);
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                      children: [
                        const _GameCard(),
                        gap,
                        if (wide)
                          const IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(flex: 2, child: _DeveloperCard()),
                                gap,
                                Expanded(flex: 3, child: _BusinessCard()),
                              ],
                            ),
                          )
                        else ...const [_DeveloperCard(), gap, _BusinessCard()],
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Ocean Escape v$_appVersion  ·  Developed by $kDevName  ·  Powered by $kBizName',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const BannerAdView(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared rounded panel.
class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.gradient});
  final Widget child;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: gradient == null ? _panel.withValues(alpha: 0.88) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: child,
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(AssetsRes.OCEAN_ESCAPE, width: 84, height: 84, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'Ocean Escape',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _Tag(text: 'v$_appVersion', color: _accent),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  kGameDescription,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Feature(icon: Icons.map_rounded, text: '4 Ocean Zones'),
                    _Feature(icon: Icons.set_meal_rounded, text: '8 Fish to Unlock'),
                    _Feature(icon: Icons.bolt_rounded, text: '5 Power-ups'),
                    _Feature(icon: Icons.monetization_on_rounded, text: 'Earn Gold'),
                    _Feature(icon: Icons.wifi_off_rounded, text: 'Play Offline'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(icon: Icons.code_rounded, text: 'DEVELOPER'),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF8A3D)]),
                  boxShadow: [BoxShadow(color: _accent.withValues(alpha: 0.4), blurRadius: 14)],
                ),
                child: const Text(
                  'AA',
                  style: TextStyle(color: _panel, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      kDevName,
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kDevRole,
                      style: TextStyle(color: Colors.amber.shade200, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _LinkChip(icon: Icons.public_rounded, label: kDevPortfolioDisplay, url: kDevPortfolioUrl),
              _LinkChip(icon: Icons.chat_rounded, label: 'WhatsApp', url: kWhatsappPersonalUrl),
            ],
          ),
        ],
      ),
    );
  }
}

class _BusinessCard extends StatelessWidget {
  const _BusinessCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3949AB), Color(0xFF1A1330)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _SectionLabel(icon: Icons.business_center_rounded, text: 'BUILT BY'),
              Spacer(),
              Text(
                kBizName,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            kBizTagline,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final s in kBizServices) _Tag(text: s, color: const Color(0xFF8FD8FF))],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _WebsiteButton(onTap: () => _openUrl(context, kBizWebsiteUrl)),
              ),
              const SizedBox(width: 8),
              const _IconLink(icon: Icons.facebook_rounded, url: kBizFacebookUrl, tooltip: 'Facebook'),
              const SizedBox(width: 8),
              const _IconLink(icon: Icons.work_rounded, url: kBizLinkedInUrl, tooltip: 'LinkedIn'),
              const SizedBox(width: 8),
              const _IconLink(icon: Icons.chat_rounded, url: kWhatsappBusinessUrl, tooltip: 'WhatsApp'),
            ],
          ),
        ],
      ),
    );
  }
}

class _WebsiteButton extends StatelessWidget {
  const _WebsiteButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _accent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.language_rounded, color: _panel, size: 18),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Visit $kBizWebsiteDisplay',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _panel, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.north_east_rounded, color: _panel, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconLink extends StatelessWidget {
  const _IconLink({required this.icon, required this.url, required this.tooltip});
  final IconData icon;
  final String url;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _openUrl(context, url),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({required this.icon, required this.label, required this.url});
  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openUrl(context, url),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _accent, size: 16),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(width: 4),
              Icon(Icons.north_east_rounded, color: Colors.white.withValues(alpha: 0.5), size: 13),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _accent, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _accent, size: 14),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
