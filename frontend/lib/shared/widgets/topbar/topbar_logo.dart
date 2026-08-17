import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_assets.dart';

class TopbarLogo extends StatelessWidget {
  const TopbarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Image.asset(
        AppAssets.logoClinical,
        width: 100,
        height: 26,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "Pra",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF13294B),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0,
                ),
              ),
              Text(
                "CH",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF24C06F),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              Text(
                "tiz",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF13294B),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
