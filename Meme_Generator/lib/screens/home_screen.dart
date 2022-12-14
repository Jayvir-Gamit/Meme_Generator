import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meme_generator/constants/routes.dart';
import 'package:meme_generator/provider/app_provider.dart';
import 'package:meme_generator/screens/main_app_screen.dart';
import 'package:meme_generator/utils/json_utils.dart';
import 'package:meme_generator/widgets/bounce_animation.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:share/share.dart';

class HomeScreen extends HookConsumerWidget {
  //const HomeScreen({Key? key}) : super(key: key);

  File? file;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBackground = ref.watch(appProvider).selectedBackground;
    final templates = ref.watch(appProvider).templates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a background'),
        actions: [
          IconButton(
            onPressed: () async {
              final image = await ImagePicker().pickImage(source: ImageSource.gallery);
              if(image==null) return;
              await Share.shareFiles([image.path]);
              // Share.share('');
            },
            icon: Icon(Icons.share_outlined),
          )
        ],
      ),
      body: FocusDetector(
        onFocusGained: () async {
          ref.read(appProvider.notifier).emptyTextWidgets();
          final templatesData = await readJson();
          ref.read(appProvider.notifier).setTemplates(templatesData);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: GridView.builder(
            key: const Key('GridViewBuilder'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 0.8,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemBuilder: (ctx, index) {
              return BounceAnimation(
                onPress: () {
                  ref.read(appProvider.notifier).setSelectedBackground(
                        templates[index].backgroundElement,
                      );
                  ref
                      .read(appProvider.notifier)
                      .setTextWidgets(templates[index].textElements);

                  ref.read(appProvider.notifier).setTemplateId(
                        templates[index].id,
                      );
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: templates[index].previewUrl != null
                              ? FileImage(
                                  File(templates[index].previewUrl as String),
                                ) as ImageProvider
                              : NetworkImage(
                                  templates[index].backgroundElement.url,
                                ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: selectedBackground?.id ==
                                  templates[index].backgroundElement.id
                              ? Colors.green
                              : Colors.grey.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            itemCount: templates.length,
          ),
        ),
      ),

      // Original code
      floatingActionButton: selectedBackground != null
          ? FloatingActionButton(
              onPressed: () async {
                Navigator.pushNamed(
                  context,
                  Routes.generateMeme,
                  arguments: MainAppScreenArguments(),
                );
              },
              child: const Icon(
                Icons.chevron_right,
                size: 30,
              ),
            )
          : null,

        // Change by me
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.all(30.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: <Widget>[
        //       FloatingActionButton(
        //         onPressed: () async {
        //           final image = await ImagePicker().pickImage(source: ImageSource.gallery);
        //           if(image==null) return;
        //           else{
        //             Navigator.pushNamed(
        //               context,
        //               //context
        //               Routes.generateMeme,
        //               arguments: MainAppScreenArguments(),
        //             );
        //           }
        //
        //         },
        //         child: const Icon(
        //           Icons.photo_library_outlined,
        //           size: 30,
        //         ),
        //       ),
        //       FloatingActionButton(
        //         onPressed: () async {
        //           Navigator.pushNamed(
        //             context,
        //             Routes.generateMeme,
        //             arguments: MainAppScreenArguments(),
        //           );
        //         },
        //         child: const Icon(
        //           Icons.chevron_right,
        //           size: 30,
        //         ),
        //       )
        //     ],
        //   ),
        // )
    );
  }

  // getgal() async {
  //   final image = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if(image==null) return;
  //
  //   setState((){
  //     file = File(image.path);
  //   });
  // }
}

