import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/lumiere_theme.dart';
import '../theme/palette.dart';
import 'paper_button.dart';
import 'round_button.dart';

/// Barrière parentale : une multiplication écrite en lettres (« sept fois huit »),
/// facile pour un adulte, difficile pour un petit enfant. Renvoie vrai si réussie.
Future<bool> showParentalGate(BuildContext context, {math.Random? random}) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x993B2418),
    builder: (context) => ParentalGate(random: random ?? math.Random()),
  );
  return ok ?? false;
}

const _words = ['zéro', 'un', 'deux', 'trois', 'quatre', 'cinq', 'six', 'sept', 'huit', 'neuf'];

class ParentalGate extends StatefulWidget {
  const ParentalGate({super.key, required this.random});

  final math.Random random;

  @override
  State<ParentalGate> createState() => ParentalGateState();
}

class ParentalGateState extends State<ParentalGate> {
  late int a;
  late int b;
  String typed = '';
  bool wrong = false;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  void _newQuestion() {
    a = 3 + widget.random.nextInt(7);
    b = 3 + widget.random.nextInt(7);
  }

  String get question => 'Combien font ${_words[a]} fois ${_words[b]} ?';

  void press(String key) {
    setState(() {
      wrong = false;
      if (key == '⌫') {
        if (typed.isNotEmpty) typed = typed.substring(0, typed.length - 1);
      } else if (typed.length < 2) {
        typed += key;
      }
    });
  }

  void submit() {
    if (int.tryParse(typed) == a * b) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        wrong = true;
        typed = '';
        _newQuestion();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 420;
    final key = compact ? 44.0 : 54.0;
    Widget keyButton(String label) => Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        width: key,
        height: key,
        child: Material(
          color: Palette.cream,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            key: ValueKey('gate-$label'),
            borderRadius: BorderRadius.circular(14),
            onTap: () => press(label),
            child: Center(child: Text(label, style: LumiereText.title(22))),
          ),
        ),
      ),
    );

    return Dialog(
      backgroundColor: Palette.paper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock_rounded, color: Palette.inkSoft),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Pour les parents', style: LumiereText.title(compact ? 20 : 24)),
                        ),
                        RoundPaperButton(
                          icon: Icons.close_rounded,
                          label: 'Fermer',
                          size: 40,
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(question, style: LumiereText.text(compact ? 18 : 20, bold: true)),
                    const SizedBox(height: 10),
                    Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Palette.cream,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: wrong ? Palette.ember : const Color(0xFFE2C9A6), width: 2),
                      ),
                      child: Text(typed.isEmpty ? ' ' : typed, style: LumiereText.title(28)),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: wrong
                          ? Text(
                              'Ce n’est pas ça. Demande à un adulte !',
                              style: LumiereText.text(15, color: Palette.ember),
                            )
                          : null,
                    ),
                    PaperButton(
                      label: 'Valider',
                      size: PaperButtonSize.small,
                      onPressed: typed.isEmpty ? null : submit,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final row in const [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                    ['0', '⌫'],
                  ])
                    Row(mainAxisSize: MainAxisSize.min, children: [for (final k in row) keyButton(k)]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
