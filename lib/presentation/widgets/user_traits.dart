import 'package:flutter/material.dart';
import '../../data/models/trait_model.dart';

class UserTraits extends StatelessWidget {
  final List<TraitModel> traits;
  final double height;
  final double itemWidth;
  final double itemHeight;
  final double spacing;

  const UserTraits({
    super.key,
    required this.traits,
    this.height = 120,
    this.itemWidth = 120,
    this.itemHeight = 40,
    this.spacing = 8,
  });

  IconData? _parseIconData(String iconData) {
    try {
      final codePoint = int.parse(iconData, radix: 16);
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (e) {
      return null;
    }
  }

  Widget _buildTraitBubble(TraitModel trait) {
    return Container(
      width: itemWidth,
      height: itemHeight,
      margin: EdgeInsets.symmetric(horizontal: spacing / 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(itemHeight / 2),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: itemHeight,
            height: itemHeight,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(itemHeight / 2),
            ),
            child: Center(
              child: Icon(
                _parseIconData(trait.iconData) ?? Icons.star,
                color: Colors.white,
                size: itemHeight * 0.6,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                trait.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: traits.length,
          itemBuilder: (context, index) => _buildTraitBubble(traits[index]),
        ),
      ),
    );
  }
}
