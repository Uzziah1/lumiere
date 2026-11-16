import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../save/game_state.dart';
import '../save/save_data.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import '../version.dart';
import '../widgets/paper_backdrop.dart';
import '../widgets/parental_gate.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/round_button.dart';
import '../world/world.dart';
import 'privacy.dart';

/// L'espace parents : progression des enfants, réglages, à propos.
/// On y entre par la barrière parentale.
class ParentsScreen extends StatefulWidget {
  const ParentsScreen({super.key, this.skipGate = false, this.initialTab = ParentsTab.children});

  /// Pour les tests : entrer sans la barrière.
  final bool skipGate;
  final ParentsTab initialTab;

  @override
  State<ParentsScreen> createState() => ParentsScreenState();
}

enum ParentsTab { children, settings, about }

class ParentsScreenState extends State<ParentsScreen> {
  late bool unlocked = widget.skipGate;
  late ParentsTab tab = widget.initialTab;

  @override
  void initState() {
    super.initState();
    if (!unlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final ok = await showParentalGate(context);
        if (!mounted) return;
        if (ok) {
          setState(() => unlocked = true);
        } else {
          _leave();
        }
      });
    }
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperBackdrop(
        child: SafeArea(
          child: !unlocked
              ? const SizedBox.expand()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 420;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Rail(
                          tab: tab,
                          compact: compact,
                          onBack: _leave,
                          onTab: (t) => setState(() => tab = t),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            key: ValueKey(tab),
                            padding: EdgeInsets.fromLTRB(8, compact ? 8 : 20, 20, 20),
                            child: switch (tab) {
                              ParentsTab.children => const _ChildrenTab(),
                              ParentsTab.settings => const _SettingsTab(),
                              ParentsTab.about => const _AboutTab(),
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.tab, required this.compact, required this.onBack, required this.onTab});

  final ParentsTab tab;
  final bool compact;
  final VoidCallback onBack;
  final void Function(ParentsTab) onTab;

  @override
  Widget build(BuildContext context) {
    final items = [
      (ParentsTab.children, Icons.child_care_rounded, 'Enfants'),
      (ParentsTab.settings, Icons.tune_rounded, 'Réglages'),
      (ParentsTab.about, Icons.info_outline_rounded, 'À propos'),
    ];
    return Container(
      width: compact ? 120 : 170,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 8 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundPaperButton(
            icon: Icons.arrow_back_rounded,
            label: 'Quitter l’espace parents',
            size: compact ? 44 : 52,
            onPressed: onBack,
          ),
          SizedBox(height: compact ? 8 : 16),
          Text('Espace parents', style: LumiereText.title(compact ? 16 : 20)),
          SizedBox(height: compact ? 6 : 12),
          for (final (t, icon, label) in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Semantics(
                button: true,
                selected: t == tab,
                label: label,
                excludeSemantics: true,
                child: Material(
                  color: t == tab ? Palette.cream : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    key: ValueKey('tab-${t.name}'),
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onTab(t),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Icon(icon, color: t == tab ? Palette.lagoonDeep : Palette.inkSoft, size: 22),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(label, style: LumiereText.title(compact ? 14 : 16, weight: 500)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String formatDuration(Duration d) {
  final minutes = d.inMinutes;
  if (minutes < 1) return 'moins d’une minute';
  if (minutes < 60) return '$minutes min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '$h h' : '$h h ${m.toString().padLeft(2, '0')}';
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        type: MaterialType.card,
        color: Palette.cream,
        elevation: 3,
        shadowColor: Palette.shadow,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: double.infinity,
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}

class _ChildrenTab extends StatelessWidget {
  const _ChildrenTab();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Les enfants', style: LumiereText.title(26)),
        const SizedBox(height: 10),
        if (state.profiles.isEmpty)
          Text('Aucun profil pour l’instant.', style: LumiereText.text(17, color: Palette.inkSoft)),
        for (final p in state.profiles) _ChildCard(profile: p),
        if (state.canAddProfile)
          TextButton.icon(
            key: const ValueKey('parents-add'),
            onPressed: () => context.push('/profils/nouveau'),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Ajouter un enfant',
              style: LumiereText.title(17, weight: 500, color: Palette.lagoonDeep),
            ),
          ),
      ],
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    final stickers = lot1.where((i) => state.progress(i.id, profileId: profile.id).sticker).length;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(avatar: profile.avatar, size: 54),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: LumiereText.title(22)),
                    Text(
                      '${profile.age.label} (${profile.age.ages})',
                      style: LumiereText.text(15, color: Palette.inkSoft),
                    ),
                  ],
                ),
              ),
              TextButton(
                key: ValueKey('parents-edit-${profile.id}'),
                onPressed: () => context.push('/profils/${profile.id}'),
                child: const Text('Modifier'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 22,
            runSpacing: 6,
            children: [
              _Fact(
                icon: Icons.today_rounded,
                text: 'Aujourd’hui : ${formatDuration(state.playtimeToday(profile.id))}',
              ),
              _Fact(
                icon: Icons.date_range_rounded,
                text: '7 derniers jours : ${formatDuration(state.playtimeWeek(profile.id))}',
              ),
              _Fact(
                icon: Icons.star_rounded,
                text: '${state.totalStars(profile.id)} étoiles sur ${lot1.length * 5}',
              ),
              _Fact(icon: Icons.verified_rounded, text: '$stickers autocollants sur ${lot1.length}'),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              for (final island in lot1)
                Semantics(
                  label:
                      '${island.title} : ${state.progress(island.id, profileId: profile.id).stars} étoiles',
                  excludeSemantics: true,
                  child: Container(
                    width: 190,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Palette.paper, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            island.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LumiereText.text(13),
                          ),
                        ),
                        for (var i = 0; i < 5; i++)
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: i < state.progress(island.id, profileId: profile.id).stars
                                ? Palette.gold
                                : const Color(0xFFE8D9C6),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Palette.lagoonDeep),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: LumiereText.text(15))),
      ],
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    final s = state.settings;
    // Toujours repartir des réglages actuels (deux touches rapprochées ne s'écrasent pas).
    void set(Settings Function(Settings current) change) => state.updateSettings(change(state.settings));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Réglages', style: LumiereText.title(26)),
        const SizedBox(height: 10),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Toggle(
                key: const ValueKey('set-narration'),
                title: 'Voix de la conteuse',
                subtitle: 'Sans la voix, les sous-titres s’affichent pour tous les âges.',
                value: s.narration,
                onChanged: (v) => set((c) => c.copyWith(narration: v)),
              ),
              _Toggle(
                key: const ValueKey('set-effects'),
                title: 'Bruitages',
                value: s.effects,
                onChanged: (v) => set((c) => c.copyWith(effects: v)),
              ),
              const Divider(),
              _Choice<SubtitleMode>(
                title: 'Sous-titres du récit',
                value: s.subtitles,
                options: const [
                  (SubtitleMode.auto, 'Selon l’âge'),
                  (SubtitleMode.always, 'Toujours'),
                  (SubtitleMode.never, 'Jamais'),
                ],
                onChanged: (v) => set((c) => c.copyWith(subtitles: v)),
              ),
            ],
          ),
        ),
        _Card(
          child: Column(
            children: [
              _Toggle(
                key: const ValueKey('set-motion'),
                title: 'Réduire les animations',
                subtitle: 'Les décors restent immobiles (aussi activé par le réglage du téléphone).',
                value: s.reduceMotion,
                onChanged: (v) => set((c) => c.copyWith(reduceMotion: v)),
              ),
              _Toggle(
                key: const ValueKey('set-large'),
                title: 'Textes plus grands',
                value: s.largeText,
                onChanged: (v) => set((c) => c.copyWith(largeText: v)),
              ),
            ],
          ),
        ),
        _Card(
          child: _Choice<int>(
            title: 'Temps de jeu par jour et par enfant',
            subtitle:
                'Quand le temps est écoulé, Colombe dit « À demain ! ». Un parent peut ajouter du temps.',
            value: s.dailyLimit,
            options: [for (final m in Settings.dailyLimitChoices) (m, m == 0 ? 'Sans limite' : '$m min')],
            onChanged: (v) => set((c) => c.copyWith(dailyLimit: v)),
          ),
        ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeThumbColor: Palette.lagoon,
      title: Text(title, style: LumiereText.title(18, weight: 500)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: LumiereText.text(14, color: Palette.inkSoft)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _Choice<T> extends StatelessWidget {
  const _Choice({
    required this.title,
    this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final T value;
  final List<(T, String)> options;
  final void Function(T) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: LumiereText.title(18, weight: 500)),
        if (subtitle != null) Text(subtitle!, style: LumiereText.text(14, color: Palette.inkSoft)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (v, label) in options)
              ChoiceChip(
                key: ValueKey('choice-$title-$v'),
                label: Text(label),
                selected: v == value,
                selectedColor: Palette.gold,
                onSelected: (_) => onChanged(v),
              ),
          ],
        ),
      ],
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) {
    Widget section(String title, String body) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: LumiereText.title(17)),
          const SizedBox(height: 2),
          Text(body, style: LumiereText.text(15)),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('À propos', style: LumiereText.title(26)),
        const SizedBox(height: 4),
        Text(
          'Lumière — la Bible en jeux · version $appVersion',
          style: LumiereText.text(16, color: Palette.inkSoft),
        ),
        const SizedBox(height: 10),
        _Card(
          child: Text(
            'Lumière est gratuit, sans publicité et sans collecte de données. Il fait découvrir les histoires de la Bible '
            'aux enfants de 4 à 12 ans, en restant fidèle au texte biblique. Les versets sont tirés de la Louis Segond 1910.',
            style: LumiereText.text(16),
          ),
        ),
        Text('Politique de confidentialité', style: LumiereText.title(22)),
        const SizedBox(height: 8),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final (t, b) in privacySections) section(t, b)],
          ),
        ),
        Text('Crédits et licences', style: LumiereText.title(22)),
        const SizedBox(height: 8),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final (t, b) in credits) section(t, b)],
          ),
        ),
      ],
    );
  }
}
