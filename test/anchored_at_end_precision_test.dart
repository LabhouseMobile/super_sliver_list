import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:super_sliver_list/super_sliver_list.dart";

void main() {
  group("SuperSliverList anchoredAtEnd", () {
    testWidgets(
        "does not treat an unscrolled viewport as scrolled because of float "
        "rounding in the preceding slivers", (tester) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final controller = ScrollController();
      addTearDown(controller.dispose);

      // Fractional header heights make `viewportMainAxisExtent -
      // remainingPaintExtent` (built by subtraction) differ from
      // `precedingScrollExtent` (built by addition) by ~1e-13 even though the
      // viewport is not scrolled.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              controller: controller,
              physics: const BouncingScrollPhysics(),
              slivers: [
                for (final height in const [62.0, 54.9, 50.0, 50.0])
                  SliverToBoxAdapter(child: SizedBox(height: height)),
                // 3 * 80 + 2 separators = 242, which fits in the viewport and
                // differs from the default estimate of 100 per item.
                SuperSliverList.separated(
                  itemCount: 3,
                  itemBuilder: (context, index) => const SizedBox(height: 80),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 1),
                ),
              ],
            ),
          ),
        ),
      );

      // First frame must not have been shifted by a scroll offset correction.
      expect(controller.position.pixels, 0);

      await tester.pumpAndSettle();
      expect(controller.position.pixels, 0);
    });
  });
}
