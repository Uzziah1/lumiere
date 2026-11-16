import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../audio/audio.dart';
import '../save/game_state.dart';
import '../story/common_lines.dart';
import '../save/save_data.dart';
import '../story/age_group.dart';
import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import '../widgets/age_card.dart';
import '../widgets/paper_backdrop.dart';
import '../widgets/paper_button.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/round_button.dart';

/// Créer ou modifier un profil : prénom, âge, animal.
class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key, this.profileId});

  /// Null pour un nouveau profil.
  final String? profileId;

  @override
  State<ProfileFormScreen> createState() => ProfileFormScreenState();
}

class ProfileFormScreenState extends State<ProfileFormScreen> {
  final _name = TextEditingController();
  AgeGroup? age;
  String avatar = avatarChoices.first;
  bool _showErrors = false;
  Profile? _editing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = GameScope.read(context);
      if (widget.profileId != null) {
        final p = state.profiles.where((p) => p.id == widget.profileId).firstOrNull;
        if (p == null) {
          context.go('/profils');
          return;
        }
        setState(() {
          _editing = p;
          _name.text = p.name;
          age = p.age;
          avatar = p.avatar;
        });
      } else {
        AudioScope.of(context).narrator
            .play(commonAudioPath('new_profile', 'all'), text: 'Comment t’appelles-tu ?');
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get valid => GameState.cleanName(_name.text).isNotEmpty && age != null;

  void save() {
    if (!valid) {
      setState(() => _showErrors = true);
      return;
    }
    final state = GameScope.read(context);
    AudioScope.of(context).sfx.play(Sfx.success);
    if (_editing != null) {
      state.updateProfile(_editing!.copyWith(name: _name.text, age: age, avatar: avatar));
      context.pop();
    } else {
      state.addProfile(name: _name.text, age: age!, avatar: avatar);
      context.go('/carte');
    }
  }

  Future<void> _delete() async {
    final p = _editing!;
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.paper,
        title: Text('Supprimer le profil de ${p.name} ?', style: LumiereText.title(22)),
        content: Text('Ses étoiles et ses autocollants seront effacés.', style: LumiereText.text(17)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            key: const ValueKey('confirm-delete'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (sure == true && mounted) {
      GameScope.read(context).deleteProfile(p.id);
      context.go('/profils');
    }
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.profileId != null;
    return Scaffold(
      body: PaperBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 420;
              final cardW = ((constraints.maxWidth - 120) / 3).clamp(100.0, 170.0);
              final nameMissing = _showErrors && GameState.cleanName(_name.text).isEmpty;
              return Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(72, compact ? 8 : 16, 72, 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              editing ? 'Modifier le profil' : 'Nouveau joueur',
                              style: LumiereText.title(compact ? 26 : 36),
                            ),
                            SizedBox(height: compact ? 10 : 18),
                            _Label('Comment t’appelles-tu ?', compact: compact),
                            SizedBox(
                              width: 360,
                              child: TextField(
                                key: const ValueKey('profile-name'),
                                controller: _name,
                                maxLength: Profile.maxNameLength,
                                textAlign: TextAlign.center,
                                textCapitalization: TextCapitalization.words,
                                style: LumiereText.title(compact ? 22 : 26, weight: 500),
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: 'Ton prénom',
                                  hintStyle: LumiereText.title(
                                    22,
                                    weight: 400,
                                    color: const Color(0x667A3F25),
                                  ),
                                  filled: true,
                                  fillColor: Palette.cream,
                                  errorText: nameMissing ? 'Écris ton prénom (un adulte peut t’aider)' : null,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: compact ? 10 : 20),
                            _Label('Quel âge as-tu ?', compact: compact, error: _showErrors && age == null),
                            Wrap(
                              spacing: 14,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: [
                                for (final a in AgeGroup.values)
                                  AgeCard(
                                    key: ValueKey('profile-age-${a.name}'),
                                    age: a,
                                    width: cardW,
                                    compact: true,
                                    selected: age == a,
                                    onTap: () => setState(() => age = a),
                                  ),
                              ],
                            ),
                            SizedBox(height: compact ? 10 : 20),
                            _Label('Choisis ton animal', compact: compact),
                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: [
                                for (final a in avatarChoices)
                                  Semantics(
                                    button: true,
                                    selected: avatar == a,
                                    label: 'Avatar ${a == 'dove' ? 'colombe' : a}',
                                    excludeSemantics: true,
                                    child: GestureDetector(
                                      key: ValueKey('profile-avatar-$a'),
                                      onTap: () => setState(() => avatar = a),
                                      child: ProfileAvatar(
                                        avatar: a,
                                        size: compact ? 54 : 70,
                                        selected: avatar == a,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: compact ? 14 : 26),
                            Wrap(
                              spacing: 16,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: [
                                if (_editing != null)
                                  PaperButton.secondary(
                                    label: 'Supprimer',
                                    icon: Icons.delete_outline_rounded,
                                    onPressed: _delete,
                                  ),
                                PaperButton(
                                  label: editing ? 'Enregistrer' : 'C’est parti !',
                                  icon: editing ? Icons.check_rounded : Icons.arrow_forward_rounded,
                                  size: compact ? PaperButtonSize.small : PaperButtonSize.large,
                                  onPressed: save,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 8,
                    child: RoundPaperButton(
                      icon: Icons.arrow_back_rounded,
                      label: 'Retour',
                      size: compact ? 44 : 54,
                      onPressed: _back,
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

class _Label extends StatelessWidget {
  const _Label(this.text, {required this.compact, this.error = false});

  final String text;
  final bool compact;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: LumiereText.title(
          compact ? 17 : 21,
          weight: 500,
          color: error ? Palette.ember : Palette.inkSoft,
        ),
      ),
    );
  }
}
