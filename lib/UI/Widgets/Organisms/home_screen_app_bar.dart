import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ssda/utils/constent.dart';

class HomeScreenAppBar extends StatelessWidget {
  const HomeScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight + 15,
      title: InkWell(
        onTap: () {
        },
        child: Text(
          'श्रीडूँगरगढ़ One',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: kblue,

            fontSize: 22,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Colors.black,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.person,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pushNamed('/profile');
          },
        ),
      ],

    );
  }
}
