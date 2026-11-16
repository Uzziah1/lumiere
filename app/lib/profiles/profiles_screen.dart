import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../audio/audio.dart';
import '../save/game_state.dart';
import '../story/common_lines.dart';
import '../save/save_data.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import '../widgets/colombe_bubble.dart';
import '../widgets/paper_backdrop.dart';
import '../widgets/parental_gate.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/round_button.dart';

/// « Qui joue ? » : l'enfant touche son médaillon pour partir sur la carte.
/// Les parents peuvent modifier ou supprimer un profil (derrière la barrière).
class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  bool _manage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GameScope.read(context).profiles.isEmpty) {
        context.pushReplacement('/profils/nouveau');
      } else {
        AudioScope.of(context).narrator.play(commonAudioPath('who', 'all'), text: 'Qui joue aujourd’hui ?');
      }
    });
  }

  void _open(Profile profile) {
    final audio = AudioScope.of(context);
    audio.sfx.play(Sfx.tap);
    if (_manage) {
      context.push('/profils/${profile.id}');
      return;
    }
    GameScope.read(context).select(profile.id);
    audio.narrator.stop();
    context.go('/carte');
  }

  Future<void> _toggleManage() async {
    if (_manage) {
      setState(() => _manage = false);
      return;
    }
    if (await showParentalGate(context) && mounted) setState(() => _manage = true);
  }

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    return Scaffold(
      body: PaperBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 420;
              final avatar = compact ? 76.0 : 110.0;
              return Stack(
                children: [
                  Positioned(
                    left: 12,
                    top: 8,
                    child: RoundPaperButton(
                      icon: Icons.home_rounded,
                      label: 'Accueil',
                      size: compact ? 44 : 54,
                      onPressed: () => context.go('/'),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 8,
                    child: RoundPaperButton(
                      icon: _manage ? Icons.check_rounded : Icons.settings_rounded,
                      label: _manage ? 'Terminer' : 'Gérer les profils (parents)',
                      size: compact ? 44 : 54,
                      onPressed: _toggleManage,
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ColombeBubble(
                            text: _manage ? 'Quel profil veux-tu modifier ?' : 'Qui joue aujourd’hui ?',
                            size: compact ? 38 : 52,
                          ),
                          SizedBox(height: compact ? 14 : 30),
                          Wrap(
                            spacing: compact ? 18 : 30,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: [
                              for (final p in state.profiles)
                                _ProfileTile(
                                  key: ValueKey('profile-${p.id}'),
                                  profile: p,
                                  stars: state.totalStars(p.id),
                                  size: avatar,
                                  editing: _manage,
                                  onTap: () => _open(p),
                                ),
                              if (state.canAddProfile && !_manage)
                                _NewTile(size: avatar, onTap: () => context.push('/profils/nouveau')),
                            ],
                          ),
                        ],
                      ),
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

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    super.key,
    required this.profile,
    required this.stars,
    required this.size,
    required this.editing,
    required this.onTap,
  });

  final Profile profile;
  final int stars;
  final double size;
  final bool editing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: editing ? 'Modifier le profil de ${profile.name}' : '${profile.name}, $stars étoiles',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: size * 1.3,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ProfileAvatar(avatar: profile.avatar, size: size),
                  if (editing)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Palette.lagoon, shape: BoxShape.circle),
                        child: const Icon(Icons.edit_rounded, color: Palette.cream, size: 20),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LumiereText.title(size * 0.22),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Palette.gold, size: 20),
                    Text(' $stars', style: LumiereText.title(16, weight: 500, color: Palette.inkSoft)),
                    Text('  ·  ${profile.age.label}', style: LumiereText.text(14, color: Palette.inkSoft)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewTile extends StatelessWidget {
  const _NewTile({required this.size, required this.onTap});

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Nouveau joueur',
      excludeSemantics: true,
      child: GestureDetector(
        key: const ValueKey('profile-new'),
        onTap: onTap,
        child: SizedBox(
          width: size * 1.3,
          child: Column(
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x33FFFFFF),
                  border: Border.all(color: const Color(0x88B07A4F), width: 3),
                ),
                child: Icon(Icons.add_rounded, size: size * 0.5, color: const Color(0xAAB07A4F)),
              ),
              const SizedBox(height: 8),
              Text('Nouveau', style: LumiereText.title(size * 0.22, color: Palette.inkSoft)),
            ],
          ),
        ),
      ),
    );
  }
}
