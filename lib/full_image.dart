import 'package:flutter/material.dart';

class FullImageView extends StatefulWidget {
  final String imageUrl;

  const FullImageView({super.key, required this.imageUrl});

  @override
  State<FullImageView> createState() => _FullImageViewState();
}

class _FullImageViewState extends State<FullImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Hero(
              tag: 'image',
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  widget.imageUrl,
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
